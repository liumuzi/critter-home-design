import argparse
import os
import subprocess
import sys

import imageio_ffmpeg


def build_output_path(input_path: str, output_path: str | None) -> str:
    if output_path:
        return output_path
    base, ext = os.path.splitext(input_path)
    return f"{base}_1280x720{ext}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert a video to 1280x720.")
    parser.add_argument("input", help="Input video path")
    parser.add_argument("-o", "--output", help="Output video path")
    args = parser.parse_args()

    input_path = os.path.abspath(args.input)
    output_path = os.path.abspath(build_output_path(input_path, args.output))

    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input file not found: {input_path}")

    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()

    cmd = [
        ffmpeg_exe,
        "-y",
        "-i",
        input_path,
        "-vf",
        "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2",
        "-c:v",
        "libx264",
        "-preset",
        "medium",
        "-crf",
        "23",
        "-c:a",
        "aac",
        "-b:a",
        "192k",
        output_path,
    ]

    print(f"Using ffmpeg: {ffmpeg_exe}")
    print(f"Input:  {input_path}")
    print(f"Output: {output_path}")

    result = subprocess.run(cmd, check=False)
    if result.returncode != 0:
        print(f"ffmpeg failed with exit code {result.returncode}", file=sys.stderr)
        return result.returncode

    print(f"Done. Output file created: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())