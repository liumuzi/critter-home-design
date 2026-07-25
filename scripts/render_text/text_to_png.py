"""
Text-to-PNG Generator
将文字渲染为透明底 PNG 图片，支持指定本地字体、字号和加粗。

用法:
    python text_to_png.py "你好世界" --font "assets/fonts/HanYiShenQiTuJian.ttf" --size 72 --bold

依赖: Pillow (pip install Pillow)
"""

import argparse
import os
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


class TextRenderer:
    """将文字渲染到透明底 PNG 图片的渲染器。"""

    def __init__(self, font_path: str, font_size: int = 72, bold: bool = False):
        """
        初始化渲染器。

        Args:
            font_path: 本地字体文件路径 (.ttf / .otf)。
            font_size: 字号 (px)。
            bold: 是否加粗。
        """
        if not os.path.isfile(font_path):
            raise FileNotFoundError(f"字体文件不存在: {font_path}")

        self.font_path = font_path
        self.font_size = font_size
        self.bold = bold

        # 加载字体
        self._font = ImageFont.truetype(font_path, size=font_size)

    def render(self, text: str, output_path: str, text_color: str = "#FFFFFF",
               padding: int = 0) -> str:
        """
        渲染文字到透明底 PNG 并保存。

        Args:
            text: 要渲染的文字内容。
            output_path: 输出 PNG 文件路径。
            text_color: 文字颜色 (hex 格式, 默认白色 #FFFFFF)。
            padding: 文字周围内边距 (px), 0 表示自动紧凑裁切。

        Returns:
            输出文件的绝对路径。
        """
        if not text:
            raise ValueError("text 不能为空")

        # ── 步骤 1: 测量文字实际尺寸 ──────────────────────────
        temp_img = Image.new("RGBA", (1, 1), (0, 0, 0, 0))
        temp_draw = ImageDraw.Draw(temp_img)
        bbox = temp_draw.textbbox((0, 0), text, font=self._font)

        # 加粗时需要扩展 bbox (stroke 会让文字膨胀)
        stroke_w = 1 if self.bold else 0
        text_width = bbox[2] - bbox[0] + stroke_w * 2
        text_height = bbox[3] - bbox[1] + stroke_w * 2

        # ── 步骤 2: 创建透明画布 ──────────────────────────────
        canvas_w = text_width + padding * 2
        canvas_h = text_height + padding * 2
        img = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # ── 步骤 3: 绘制文字 ──────────────────────────────────
        # 使用 stroke_width 模拟加粗: 给文字描边 (描边色=文字色),
        # 视觉上等同于笔画加粗, 适合 CJK 字体。
        anchor_x = padding - bbox[0] + stroke_w
        anchor_y = padding - bbox[1] + stroke_w

        draw.text(
            (anchor_x, anchor_y),
            text,
            font=self._font,
            fill=text_color,
            stroke_width=stroke_w,
            stroke_fill=text_color if self.bold else None,
        )

        # ── 步骤 4: 保存 ──────────────────────────────────────
        output_path = os.path.abspath(output_path)
        os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
        img.save(output_path, "PNG")
        print(f"已生成: {output_path}  ({canvas_w}x{canvas_h})")
        return output_path


# ═══════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(
        description="将文字渲染为透明底 PNG 图片",
    )
    parser.add_argument(
        "text",
        help="要渲染的文字内容",
    )
    parser.add_argument(
        "--font", "-f",
        required=True,
        help="本地字体文件路径 (.ttf / .otf)",
    )
    parser.add_argument(
        "--size", "-s",
        type=int,
        default=72,
        help="字号 (px), 默认 72",
    )
    parser.add_argument(
        "--bold", "-b",
        action="store_true",
        help="启用加粗",
    )
    parser.add_argument(
        "--color", "-c",
        default="#FFFFFF",
        help="文字颜色 (hex), 默认 #FFFFFF (白色)",
    )
    parser.add_argument(
        "--padding", "-p",
        type=int,
        default=10,
        help="文字周围内边距 (px), 默认 10",
    )
    parser.add_argument(
        "--output", "-o",
        default=None,
        help="输出 PNG 路径, 默认自动生成到 ./output/ 目录",
    )

    args = parser.parse_args()

    # 默认输出路径
    if args.output is None:
        script_dir = Path(__file__).resolve().parent.parent  # critter-home-design/
        out_dir = script_dir / "output"
        out_dir.mkdir(exist_ok=True)
        # 文件名: 文字前10字_字号[_bold].png
        slug = args.text[:10].replace("/", "_").replace("\\", "_")
        bold_suffix = "_bold" if args.bold else ""
        output_path = str(out_dir / f"{slug}_{args.size}{bold_suffix}.png")
    else:
        output_path = args.output

    try:
        renderer = TextRenderer(args.font, args.size, args.bold)
        renderer.render(args.text, output_path, args.color, args.padding)
    except Exception as e:
        print(f"错误: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
