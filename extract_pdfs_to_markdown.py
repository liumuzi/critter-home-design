from __future__ import annotations

from pathlib import Path
import re
from pypdf import PdfReader


def normalize_text(text: str) -> str:
    """Normalize line breaks and remove obvious empty noise lines."""
    # Remove control characters introduced by some PDF encodings.
    text = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]", "", text)
    lines = [line.rstrip() for line in text.replace("\r\n", "\n").replace("\r", "\n").split("\n")]
    cleaned: list[str] = []
    empty_count = 0

    for line in lines:
        if line.strip():
            cleaned.append(line)
            empty_count = 0
            continue

        empty_count += 1
        if empty_count <= 1:
            cleaned.append("")

    return "\n".join(cleaned).strip()


def extract_pdf_to_markdown(pdf_path: Path, output_path: Path) -> str:
    """Extract one PDF into a markdown file and return markdown text."""
    reader = PdfReader(str(pdf_path))
    title = pdf_path.stem

    chunks: list[str] = [f"# {title}", ""]

    for idx, page in enumerate(reader.pages, start=1):
        raw = page.extract_text() or ""
        text = normalize_text(raw)

        chunks.append(f"## 第 {idx} 页")
        chunks.append("")

        if text:
            chunks.append(text)
        else:
            chunks.append("[该页未提取到可读文本，可能为扫描图片或加密内容]")

        chunks.append("")

    md_text = "\n".join(chunks).strip() + "\n"
    output_path.write_text(md_text, encoding="utf-8")
    return md_text


def main() -> None:
    """Extract all PDFs under 策划案 and write per-file + merged markdown outputs."""
    root = Path(__file__).resolve().parent
    source_dir = root / "策划案"
    output_dir = source_dir / "markdown"
    output_dir.mkdir(parents=True, exist_ok=True)

    pdf_files = sorted(source_dir.glob("*.pdf"))
    if not pdf_files:
        print("No PDF files found.")
        return

    merged_parts: list[str] = ["# 策划案 PDF 提取汇总", ""]

    for pdf_path in pdf_files:
        md_name = f"{pdf_path.stem}.md"
        md_path = output_dir / md_name

        md_text = extract_pdf_to_markdown(pdf_path, md_path)
        merged_parts.append(f"---\n\n# 文档: {pdf_path.name}\n")
        merged_parts.append(md_text)
        print(f"Extracted: {pdf_path.name} -> {md_path.relative_to(root)}")

    merged_path = source_dir / "策划案_PDF提取汇总.md"
    merged_path.write_text("\n".join(merged_parts).strip() + "\n", encoding="utf-8")
    print(f"Merged markdown: {merged_path.relative_to(root)}")


if __name__ == "__main__":
    main()
