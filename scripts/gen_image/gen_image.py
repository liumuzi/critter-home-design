"""
OpenRouter Image Generation Tool.

Reads a JSON config file with prompts and settings, calls the OpenRouter
Image API (/api/v1/images), and saves the generated images to disk.

Supports:
  - Text-to-image generation
  - Image-to-image (reference images via URL or local file)
  - All OpenRouter image params: resolution, aspect_ratio, quality, seed, etc.

Usage:
  python gen_image.py <config.json>                    # use config file
  python gen_image.py <config.json> --dry-run          # validate only
  python gen_image.py <config.json> --api-key sk-xxx   # override API key

API key is read from (in order of priority):
  1. --api-key CLI argument
  2. OPENROUTER_API_KEY environment variable
  3. .env file in the script directory
"""

import argparse
import base64
import io
import json
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Optional

import requests
from PIL import Image


# ---------------------------------------------------------------------------
# Configuration loader
# ---------------------------------------------------------------------------

def load_env_api_key(script_dir: Path) -> Optional[str]:
    """Load OPENROUTER_API_KEY from a .env file if present."""
    env_path = script_dir / ".env"
    if not env_path.exists():
        return None
    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        if key.strip() == "OPENROUTER_API_KEY":
            return value.strip().strip('"').strip("'")
    return None


def resolve_api_key(cli_key: Optional[str]) -> str:
    """Resolve API key from CLI arg, env var, or .env file."""
    if cli_key:
        return cli_key
    env_key = os.environ.get("OPENROUTER_API_KEY")
    if env_key:
        return env_key
    file_key = load_env_api_key(Path(__file__).resolve().parent)
    if file_key:
        return file_key
    print("ERROR: No API key found. Provide it via:", file=sys.stderr)
    print("  1. --api-key argument", file=sys.stderr)
    print("  2. OPENROUTER_API_KEY environment variable", file=sys.stderr)
    print("  3. .env file with OPENROUTER_API_KEY=sk-...", file=sys.stderr)
    sys.exit(1)


# ---------------------------------------------------------------------------
# Image reference helpers
# ---------------------------------------------------------------------------

# Reference images are auto-compressed to keep request body under API limits.
# Long edge is capped at this many pixels; file is converted to JPEG if needed.
MAX_REFERENCE_LONG_EDGE = 1536
MAX_REFERENCE_SIZE_KB = 500  # soft cap — we warn if exceeded after compression


def _compress_image_for_api(image: Image.Image, original_path: str) -> tuple[bytes, str]:
    """Resize and compress an image to be API-friendly.

    Returns (image_bytes, mime_type).

    - Resizes so the longest edge <= MAX_REFERENCE_LONG_EDGE
    - Converts RGBA → RGB (JPEG-friendly) unless preserving transparency
    - Outputs as JPEG at quality 85 for raster images, PNG for transparency
    """
    w, h = image.size
    long_edge = max(w, h)
    if long_edge > MAX_REFERENCE_LONG_EDGE:
        scale = MAX_REFERENCE_LONG_EDGE / long_edge
        new_w = int(w * scale)
        new_h = int(h * scale)
        image = image.resize((new_w, new_h), Image.LANCZOS)
        print(f"  (resized reference: {w}x{h} → {new_w}x{new_h})")

    # If image has transparency, keep as PNG; otherwise convert to JPEG
    has_transparency = False
    if image.mode in ("RGBA", "P"):
        if image.mode == "RGBA":
            alpha = image.getchannel("A")
            has_transparency = alpha.getextrema()[0] < 255
        else:
            has_transparency = "transparency" in image.info
        if not has_transparency:
            image = image.convert("RGB")

    out_buf = io.BytesIO()
    if has_transparency:
        image.save(out_buf, format="PNG", optimize=True)
        mime = "image/png"
    else:
        image.save(out_buf, format="JPEG", quality=85, optimize=True)
        mime = "image/jpeg"
    return out_buf.getvalue(), mime


def encode_image_to_data_url(file_path: str) -> str:
    """Read a local image file and return a base64 data URL.

    Large images are automatically compressed to stay under API size limits.
    """
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Reference image not found: {file_path}")

    original_size_kb = path.stat().st_size / 1024

    image = Image.open(path)
    compressed_bytes, mime = _compress_image_for_api(image, file_path)
    compressed_size_kb = len(compressed_bytes) / 1024

    if original_size_kb > MAX_REFERENCE_SIZE_KB:
        print(f"  (compressed reference: {original_size_kb:.0f} KB → {compressed_size_kb:.0f} KB)")
    if compressed_size_kb > MAX_REFERENCE_SIZE_KB:
        print(f"  Warning: reference still {compressed_size_kb:.0f} KB after compression — API may reject")

    b64 = base64.b64encode(compressed_bytes).decode("utf-8")
    return f"data:{mime};base64,{b64}"


def build_input_references(refs: list[dict], base_dir: Path | None = None) -> list[dict]:
    """Convert user-friendly reference entries to OpenRouter format.

    Each entry in `refs` may be:
      - {"url": "https://..."}              → passed through
      - {"file": "path/to/image.png"}       → converted to data URL
                                              (resolved relative to base_dir if provided)
    """
    result = []
    for ref in refs:
        if "url" in ref:
            result.append({
                "type": "image_url",
                "image_url": {"url": ref["url"]},
            })
        elif "file" in ref:
            file_path = ref["file"]
            if base_dir and not Path(file_path).is_absolute():
                file_path = str((base_dir / file_path).resolve())
            data_url = encode_image_to_data_url(file_path)
            result.append({
                "type": "image_url",
                "image_url": {"url": data_url},
            })
        else:
            raise ValueError(
                f"Reference entry must have 'url' or 'file': {ref}"
            )
    return result


# ---------------------------------------------------------------------------
# API call
# ---------------------------------------------------------------------------

API_URL = "https://openrouter.ai/api/v1/images"
MAX_RETRIES = 3
RETRY_BACKOFF_BASE = 2.0  # seconds: 2, 4, 8


def call_image_api(
    api_key: str,
    payload: dict,
    dry_run: bool = False,
) -> dict:
    """Send a request to the OpenRouter Image API with automatic retries.

    Retries on connection errors and 5xx responses with exponential backoff.
    """
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    if dry_run:
        print("[DRY RUN] Would POST to:", API_URL)
        # Print a compact summary (skip huge base64 payloads)
        compact = {}
        for k, v in payload.items():
            if k == "input_references":
                compact[k] = f"[{len(v)} reference(s)]"
            else:
                compact[k] = v
        print("[DRY RUN] Payload:")
        print(json.dumps(compact, indent=2, ensure_ascii=False))
        return {}

    last_error = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = requests.post(API_URL, headers=headers, json=payload, timeout=180)
        except (requests.ConnectionError, requests.Timeout) as e:
            last_error = e
            if attempt < MAX_RETRIES:
                wait = RETRY_BACKOFF_BASE ** attempt
                print(f"  Connection error (attempt {attempt}/{MAX_RETRIES}), "
                      f"retrying in {wait:.0f}s: {e}", file=sys.stderr)
                time.sleep(wait)
                continue
            print(f"ERROR: Connection failed after {MAX_RETRIES} attempts", file=sys.stderr)
            raise

        # Retry on server errors (5xx)
        if resp.status_code >= 500:
            if attempt < MAX_RETRIES:
                wait = RETRY_BACKOFF_BASE ** attempt
                print(f"  Server error {resp.status_code} (attempt {attempt}/{MAX_RETRIES}), "
                      f"retrying in {wait:.0f}s", file=sys.stderr)
                time.sleep(wait)
                continue
            print(f"ERROR: API returned {resp.status_code} after {MAX_RETRIES} attempts", file=sys.stderr)
            try:
                print(resp.text, file=sys.stderr)
            except Exception:
                pass
            resp.raise_for_status()

        # Client errors (4xx) — do not retry
        if not resp.ok:
            print(f"ERROR: API returned {resp.status_code}", file=sys.stderr)
            try:
                print(resp.text, file=sys.stderr)
            except Exception:
                pass
            resp.raise_for_status()

        return resp.json()

    # Should not reach here, but just in case
    if last_error:
        raise last_error
    return {}


# ---------------------------------------------------------------------------
# Save helpers
# ---------------------------------------------------------------------------

def save_images(result: dict, output_dir: Path, prefix: str = "gen") -> list[Path]:
    """Decode base64 images from the API response and save to disk.

    Returns list of saved file paths.
    """
    saved = []
    data_items = result.get("data", [])

    for i, item in enumerate(data_items):
        b64 = item.get("b64_json", "")
        if not b64:
            print(f"Warning: item {i} has no b64_json, skipping")
            continue

        media_type = item.get("media_type", "image/png")
        ext = media_type.split("/")[-1] if "/" in media_type else "png"
        # Normalize: jpeg → jpg
        if ext == "jpeg":
            ext = "jpg"

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        stem = f"{prefix}_{timestamp}"
        if len(data_items) > 1:
            stem += f"_{i + 1}"
        filename = f"{stem}.{ext}"

        output_dir.mkdir(parents=True, exist_ok=True)
        filepath = output_dir / filename
        filepath.write_bytes(base64.b64decode(b64))
        print(f"Saved: {filepath}")
        saved.append(filepath)

    return saved


# ---------------------------------------------------------------------------
# Config loading & validation
# ---------------------------------------------------------------------------

REQUIRED_FIELDS = ["model"]
OPTIONAL_FIELDS = [
    "prompt", "prompts",            # single or batch prompts
    "n", "resolution", "aspect_ratio", "size", "quality",
    "output_format", "background", "output_compression", "seed",
    "stream", "input_references", "provider",
    "output_dir", "output_prefix",
]


def load_config(config_path: str) -> dict:
    """Load and validate a JSON config file.

    Must have 'model' plus either 'prompt' (single) or 'prompts' (batch array).
    """
    path = Path(config_path)
    if not path.exists():
        print(f"ERROR: Config file not found: {config_path}", file=sys.stderr)
        sys.exit(1)

    with open(path, "r", encoding="utf-8") as f:
        config = json.load(f)

    # Validate required fields
    for field in REQUIRED_FIELDS:
        if field not in config:
            print(f"ERROR: Missing required field '{field}' in config", file=sys.stderr)
            sys.exit(1)

    # Must have prompt or prompts
    if "prompt" not in config and "prompts" not in config:
        print("ERROR: Config must have 'prompt' (single) or 'prompts' (batch array)", file=sys.stderr)
        sys.exit(1)

    if "prompts" in config:
        if not isinstance(config["prompts"], list) or len(config["prompts"]) == 0:
            print("ERROR: 'prompts' must be a non-empty array", file=sys.stderr)
            sys.exit(1)
        # Validate each batch item
        for i, item in enumerate(config["prompts"]):
            if not isinstance(item, dict) or "prompt" not in item:
                print(f"ERROR: prompts[{i}] must be an object with 'prompt' key", file=sys.stderr)
                sys.exit(1)

    # Warn about unknown fields
    for key in config:
        if key not in REQUIRED_FIELDS and key not in OPTIONAL_FIELDS:
            print(f"Warning: unknown config key '{key}' — will be ignored")

    return config


def build_payload(config: dict, prompt: str, base_dir: Path | None = None) -> dict:
    """Build the API request payload from a validated config dict, a prompt string,
    and an optional base directory for resolving relative file paths."""
    payload = {
        "model": config["model"],
        "prompt": prompt,
    }

    # Copy optional fields that map directly to API params
    direct_fields = [
        "n", "resolution", "aspect_ratio", "size", "quality",
        "output_format", "background", "output_compression", "seed",
        "stream", "provider",
    ]
    for field in direct_fields:
        if field in config:
            payload[field] = config[field]

    # Handle input_references
    if "input_references" in config:
        payload["input_references"] = build_input_references(
            config["input_references"], base_dir
        )

    return payload


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Generate images via OpenRouter Image API from a JSON config."
    )
    parser.add_argument(
        "config",
        help="Path to JSON config file",
    )
    parser.add_argument(
        "--api-key",
        help="OpenRouter API key (overrides env / .env)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the request payload without calling the API",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Override output directory (default: config's output_dir or ./output/images)",
    )
    parser.add_argument(
        "--output-prefix",
        default=None,
        help="Override output filename prefix (default: config's output_prefix or 'gen')",
    )
    args = parser.parse_args()

    # Resolve API key
    api_key = resolve_api_key(args.api_key)

    # Load config (resolve file paths relative to config file's directory)
    config_path = Path(args.config).resolve()
    config_dir = config_path.parent
    config = load_config(str(config_path))

    # Collect prompts: single "prompt" or batch "prompts"
    prompt_entries: list[dict] = []
    if "prompts" in config:
        prompt_entries = config["prompts"]
    else:
        prompt_entries = [{"prompt": config["prompt"]}]

    # Resolve output location
    script_dir = Path(__file__).resolve().parent
    default_output = script_dir.parent.parent / "output" / "images"
    output_dir = Path(
        args.output_dir
        or config.get("output_dir")
        or str(default_output)
    )
    # Resolve relative output_dir against config file directory
    if not output_dir.is_absolute():
        output_dir = (config_dir / output_dir).resolve()

    total_saved = 0

    for idx, entry in enumerate(prompt_entries):
        prompt_text = entry["prompt"]
        batch_label = f"[{idx + 1}/{len(prompt_entries)}]" if len(prompt_entries) > 1 else ""

        # Per-entry override for prefix
        entry_prefix = entry.get("output_prefix") or args.output_prefix or config.get("output_prefix", "gen")

        print(f"\n{'=' * 60}")
        print(f"{batch_label} Model: {config['model']}")
        print(f"{batch_label} Prompt: {prompt_text[:100]}{'...' if len(prompt_text) > 100 else ''}")

        # Build payload
        payload = build_payload(config, prompt_text, config_dir)

        # Call API
        result = call_image_api(api_key, payload, dry_run=args.dry_run)

        if args.dry_run or not result:
            continue

        # Print usage if available
        usage = result.get("usage", {})
        if usage:
            cost = usage.get("cost")
            tokens = usage.get("total_tokens", "?")
            cost_str = f"${cost:.4f}" if cost is not None else "N/A"
            print(f"{batch_label} Usage: {tokens} tokens, cost: {cost_str}")

        # Save images
        saved = save_images(result, output_dir, entry_prefix)
        total_saved += len(saved)

    print(f"\nDone: {total_saved} image(s) saved to {output_dir}")


if __name__ == "__main__":
    main()
