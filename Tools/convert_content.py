# -*- coding: utf-8 -*-
"""Конвертер контент-таблиц CSV -> .tres для Godot 4.

Читает:
    Content/words_v01.csv     -> Game/resources/content/words_v01.tres (WordsTable)
    Content/sentences_v02.csv -> Game/resources/content/sentences_v02.tres (SentencesTable)

Формат .tres — текстовый ресурс Godot 4 (format=3). Файлы генерируются
напрямую, редактор запускать не нужно.

Запуск: python Tools/convert_content.py  (из корня репозитория или Tools/)
"""

import csv
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

SRC_WORDS = REPO_ROOT / "Content" / "words_v01.csv"
SRC_SENTENCES = REPO_ROOT / "Content" / "sentences_v02.csv"
OUT_DIR = REPO_ROOT / "Game" / "resources" / "content"

# Скрипты-классы ресурсов (ext_resource). uid не указываем: Godot восстановит
# ссылки по пути при импорте проекта.
SCRIPT_WORD = "res://scripts/resources/word_entry.gd"
SCRIPT_SENTENCE = "res://scripts/resources/sentence_entry.gd"
SCRIPT_WORDS_TABLE = "res://scripts/resources/words_table.gd"
SCRIPT_SENTENCES_TABLE = "res://scripts/resources/sentences_table.gd"


def _gd_escape(text: str) -> str:
    """Экранирование строки для литерала GDScript."""
    return text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def _tres_int(value: str) -> int:
    """Целое значение; при мусорных данных — исключение с понятным текстом."""
    try:
        return int(value.strip())
    except ValueError:
        raise ValueError(f"trust_effect должен быть целым числом, получено: {value!r}")


def _packed_string_array(values: list[str]) -> str:
    """Литерал PackedStringArray для .tres."""
    if not values:
        return "PackedStringArray()"
    parts = ", ".join(f'"{_gd_escape(v)}"' for v in values)
    return f"PackedStringArray({parts})"


def _resource_header(load_steps: int) -> list[str]:
    lines = [f'[gd_resource type="Resource" load_steps={load_steps} format=3]', ""]
    return lines


# ---------------------------------------------------------------------------
# WordsTable
# ---------------------------------------------------------------------------

def generate_words_table(rows: list[dict]) -> str:
    """Собрать текст .tres для WordsTable из строк CSV."""
    load_steps = 2 + len(rows)  # 2 ext-скрипта + записи + [resource]
    lines = _resource_header(load_steps)

    lines.append(f'[ext_resource type="Script" path="{SCRIPT_WORDS_TABLE}" id="1"]')
    lines.append(f'[ext_resource type="Script" path="{SCRIPT_WORD}" id="2"]')
    lines.append("")

    for index, row in enumerate(rows, start=1):
        lines.append(f'[sub_resource type="Resource" id="Resource_{index}"]')
        lines.append('script = ExtResource("2")')
        lines.append(f'word = "{_gd_escape(row["word"].strip())}"')
        lines.append(f'type = "{_gd_escape(row["type"].strip())}"')
        lines.append(f"trust_effect = {_tres_int(row['trust_effect'])}")
        lines.append(f'speaker = "{_gd_escape(row["speaker"].strip())}"')
        lines.append(f'reaction_text = "{_gd_escape(row["reaction_text"].strip())}"')
        lines.append("")

    entries = ", ".join(f'SubResource("Resource_{i}")' for i in range(1, len(rows) + 1))
    lines.append("[resource]")
    lines.append('script = ExtResource("1")')
    lines.append(f"entries = [{entries}]")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# SentencesTable
# ---------------------------------------------------------------------------

def generate_sentences_table(rows: list[dict]) -> str:
    """Собрать текст .tres для SentencesTable из строк CSV.

    Строки CSV с одинаковым set_id — один набор; список слов набора берём
    из первой строки набора (в остальных он повторяется).
    """
    load_steps = 2 + len(rows)
    lines = _resource_header(load_steps)

    lines.append(f'[ext_resource type="Script" path="{SCRIPT_SENTENCES_TABLE}" id="1"]')
    lines.append(f'[ext_resource type="Script" path="{SCRIPT_SENTENCE}" id="2"]')
    lines.append("")

    seen_sets: set[str] = set()
    for index, row in enumerate(rows, start=1):
        set_id = row["set_id"].strip()
        words = row["words"].split()
        lines.append(f'[sub_resource type="Resource" id="Resource_{index}"]')
        lines.append('script = ExtResource("2")')
        lines.append(f'set_id = "{_gd_escape(set_id)}"')
        lines.append(f"words = {_packed_string_array(words)}")
        lines.append(f'sentence = "{_gd_escape(row["sentence"].strip())}"')
        lines.append(f'type = "{_gd_escape(row["type"].strip())}"')
        lines.append(f"trust_effect = {_tres_int(row['trust_effect'])}")
        lines.append(f'speaker = "{_gd_escape(row["speaker"].strip())}"')
        lines.append(f'reaction_text = "{_gd_escape(row["reaction_text"].strip())}"')
        lines.append("")
        seen_sets.add(set_id)

    entries = ", ".join(f'SubResource("Resource_{i}")' for i in range(1, len(rows) + 1))
    lines.append("[resource]")
    lines.append('script = ExtResource("1")')
    lines.append(f"entries = [{entries}]")
    lines.append("")

    print(f"[convert] Наборы предложений: {len(seen_sets)} шт. ({', '.join(sorted(seen_sets))})")
    return "\n".join(lines)


def main() -> int:
    missing = [src for src in (SRC_WORDS, SRC_SENTENCES) if not src.exists()]
    for src in missing:
        print(f"[convert] Не найден исходный CSV: {src}", file=sys.stderr)
    if missing:
        return 1

    with SRC_WORDS.open(encoding="utf-8") as file:
        words = list(csv.DictReader(file))
    with SRC_SENTENCES.open(encoding="utf-8") as file:
        sentences = list(csv.DictReader(file))

    print(f"[convert] words_v01.csv: {len(words)} строк")
    print(f"[convert] sentences_v02.csv: {len(sentences)} строк")

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    words_text = generate_words_table(words)
    sentences_text = generate_sentences_table(sentences)

    out_words = OUT_DIR / "words_v01.tres"
    out_sentences = OUT_DIR / "sentences_v02.tres"
    out_words.write_text(words_text, encoding="utf-8")
    out_sentences.write_text(sentences_text, encoding="utf-8")

    print(f"[convert] Готово: {out_words}")
    print(f"[convert] Готово: {out_sentences}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
