# -*- coding: utf-8 -*-
"""Чекер покрытия наборов предложений (Content/sentences_v02.csv).

Для каждого набора перебирает все перестановки длиной 3–5 слов (без повторов
слова — чип у каждого слова один) и сравнивает со списком валидных
предложений из CSV. Все НЕпокрытые перестановки пишет в файл
Tools/uncovered_sentences.txt — геймдизайнер просматривает его и убеждается,
что там только бессмыслица (чушь). Осмысленные варианты обязаны быть
строками CSV.

Правила осмысленности (см. Docs/Prototype/content-sentences-v02.md):
    - перестановка осмысленна, если читается как высказывание (SVO и т.п.);
    - рефлексивные комбинации ("dog love dog") и обрывки ("i am not")
      осмысленными не считаются — чушь ожидаема.

Запуск: python Tools/check_sentences.py  (из корня репозитория или Tools/)
Отчёт:  Tools/uncovered_sentences.txt
"""

import csv
import itertools
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SRC_SENTENCES = REPO_ROOT / "Content" / "sentences_v02.csv"
REPORT_PATH = REPO_ROOT / "Tools" / "uncovered_sentences.txt"

MIN_WORDS = 3  # минимальная длина предложения (из механики версии 0.2)
MAX_WORDS = 5  # максимальная длина предложения


def load_sets(path: Path) -> dict[str, tuple[list[str], set[str]]]:
    """Сгруппировать CSV по set_id -> (слова набора, валидные предложения)."""
    sets: dict[str, tuple[list[str], set[str]]] = {}
    with path.open(encoding="utf-8") as file:
        for row in csv.DictReader(file):
            set_id = row["set_id"].strip()
            words, valid = sets.get(set_id, ([], set()))
            if not words:
                words = row["words"].split()
            valid.add(row["sentence"].strip().lower())
            sets[set_id] = (words, valid)
    return sets


def main() -> int:
    if not SRC_SENTENCES.exists():
        print(f"[check] Не найден CSV: {SRC_SENTENCES}", file=sys.stderr)
        return 1

    sets = load_sets(SRC_SENTENCES)

    lines: list[str] = []
    total_uncovered = 0
    print(f"[check] Наборов: {len(sets)}")
    for set_id in sorted(sets, key=lambda s: (len(s), s)):
        words, valid = sets[set_id]
        if not 4 <= len(words) <= 6:
            print(
                f"[check] ВНИМАНИЕ: набор {set_id} содержит {len(words)} слов"
                " (правило: 4–6)",
                file=sys.stderr,
            )

        covered = 0
        uncovered: list[str] = []
        for length in range(MIN_WORDS, min(MAX_WORDS, len(words)) + 1):
            for combo in itertools.permutations(words, length):
                phrase = " ".join(combo)
                if phrase in valid:
                    covered += 1
                else:
                    uncovered.append(phrase)

        total_uncovered += len(uncovered)
        print(
            f"[check] набор {set_id}: слов {len(words)}, валидных {len(valid)},"
            f" перестановок покрыто {covered}, не покрыто {len(uncovered)}"
        )
        lines.append(f"=== Набор {set_id} (слова: {' '.join(words)}) ===")
        lines.extend(uncovered)
        lines.append("")

    REPORT_PATH.write_text("\n".join(lines), encoding="utf-8")
    print(f"[check] Отчёт о непокрытых перестановках: {REPORT_PATH}")
    print("[check] Просмотри отчёт: осмысленных фраз там быть не должно.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
