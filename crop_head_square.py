"""Crop a character head into a square PNG."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def parse_args() -> argparse.Namespace:
    """Parse command line arguments for head cropping."""
    parser = argparse.ArgumentParser(
        description="Crop a character head region into a square image.",
    )
    parser.add_argument("input", type=Path, help="Source image path.")
    parser.add_argument("output", type=Path, help="Output PNG path.")
    parser.add_argument(
        "--size",
        type=int,
        default=256,
        help="Output width and height in pixels.",
    )
    parser.add_argument(
        "--head-ratio",
        type=float,
        default=0.18,
        help="Vertical focal ratio inside the opaque bounds.",
    )
    parser.add_argument(
        "--crop-ratio",
        type=float,
        default=0.52,
        help="Square crop size ratio relative to opaque bounds width.",
    )
    parser.add_argument(
        "--offset-x",
        type=float,
        default=0.0,
        help="Horizontal focal offset relative to crop size.",
    )
    parser.add_argument(
        "--offset-y",
        type=float,
        default=0.0,
        help="Vertical focal offset relative to crop size.",
    )
    return parser.parse_args()


def compute_opaque_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    """Return the opaque content bounds, or the full image when no alpha exists."""
    if "A" not in image.getbands():
        return (0, 0, image.width, image.height)

    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        return (0, 0, image.width, image.height)

    return bbox


def clamp_crop_box(
    image: Image.Image,
    center_x: float,
    center_y: float,
    side_length: float,
) -> tuple[int, int, int, int]:
    """Clamp a square crop box so it always stays inside the source image."""
    side = max(1, min(int(round(side_length)), image.width, image.height))
    left = int(round(center_x - side / 2))
    top = int(round(center_y - side / 2))

    if left < 0:
        left = 0
    if top < 0:
        top = 0
    if left + side > image.width:
        left = image.width - side
    if top + side > image.height:
        top = image.height - side

    return (left, top, left + side, top + side)


def crop_head_square(
    input_path: Path,
    output_path: Path,
    size: int,
    head_ratio: float,
    crop_ratio: float,
    offset_x: float,
    offset_y: float,
) -> tuple[int, int, int, int]:
    """Crop the head area and save it as a square PNG."""
    image = Image.open(input_path).convert("RGBA")
    left, top, right, bottom = compute_opaque_bbox(image)
    content_width = right - left
    content_height = bottom - top

    center_x = left + content_width * 0.5
    center_y = top + content_height * head_ratio

    side_length = max(content_width * crop_ratio, 32)
    center_x += side_length * offset_x
    center_y += side_length * offset_y

    crop_box = clamp_crop_box(image, center_x, center_y, side_length)
    head_image = image.crop(crop_box).resize((size, size), Image.Resampling.LANCZOS)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    head_image.save(output_path)
    return crop_box


def main() -> None:
    """Run the CLI entry point and print the chosen crop box."""
    args = parse_args()
    crop_box = crop_head_square(
        input_path=args.input,
        output_path=args.output,
        size=args.size,
        head_ratio=args.head_ratio,
        crop_ratio=args.crop_ratio,
        offset_x=args.offset_x,
        offset_y=args.offset_y,
    )
    print(f"Saved {args.output} using crop box {crop_box}")


if __name__ == "__main__":
    main()