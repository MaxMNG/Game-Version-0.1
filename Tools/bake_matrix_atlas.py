#!/usr/bin/env python3
"""Запекание атласа глифов для фона «Матрица».

Рисует все символы английского алфавита (A-Z, a-z), цифры и пунктуацию
моноширинным шрифтом в сетку PNG: белые глифы на чёрном фоне.
Шейдер `matrix_background.gdshader` выбирает глиф по индексу ячейки.

Порядок символов задаёт индекс глифа (0..GLYPH_COUNT-1); в GDScript
набор дублировать не нужно — шейдеру важен только индекс.

Использование:
    python Tools/bake_matrix_atlas.py
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# Набор глифов: 26 + 26 + 10 + 32 = 94. Сетка 16x6 (96 ячеек, 2 пустые в конце).
CHARSET: str = (
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz"
    "0123456789"
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
)
COLS: int = 16
CELL: int = 64
FONT_SIZE: int = 44
FONT_CANDIDATES: tuple[str, ...] = (
    "C:/Windows/Fonts/consola.ttf",
    "C:/Windows/Fonts/cour.ttf",
)

ROOT: Path = Path(__file__).resolve().parent.parent
OUT: Path = ROOT / "Game" / "assets" / "atlases" / "matrix_glyphs.png"


def find_font() -> Path:
    """Первый существующий моноширинный шрифт из кандидатов."""
    for candidate in FONT_CANDIDATES:
        path = Path(candidate)
        if path.is_file():
            return path
    raise FileNotFoundError("Не найден моноширинный шрифт: %s" % (FONT_CANDIDATES,))


def main() -> None:
    """Отрисовать атлас и сохранить в Game/assets/atlases/."""
    glyph_count: int = len(CHARSET)
    rows: int = (glyph_count + COLS - 1) // COLS
    atlas = Image.new("RGB", (COLS * CELL, rows * CELL), (0, 0, 0))
    draw = ImageDraw.Draw(atlas)
    font = ImageFont.truetype(str(find_font()), FONT_SIZE)
    for idx, char in enumerate(CHARSET):
        col: int = idx % COLS
        row: int = idx // COLS
        x0: int = col * CELL
        y0: int = row * CELL
        # Центрирование глифа в ячейке по его реальной рамке.
        left, top, right, bottom = draw.textbbox((0, 0), char, font=font)
        w: float = right - left
        h: float = bottom - top
        draw.text((x0 + (CELL - w) / 2 - left, y0 + (CELL - h) / 2 - top),
                  char, font=font, fill=(255, 255, 255))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(OUT)
    print("Атлас: %d глифов, сетка %dx%d, %s" % (glyph_count, COLS, rows, OUT))


if __name__ == "__main__":
    main()
