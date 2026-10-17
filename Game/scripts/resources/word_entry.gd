class_name WordEntry
extends Resource
## Запись таблицы слов версии 0.1 (мини-игра «Сбор слов»).
##
## Источник данных — `Content/words_v01.csv`, конвертируется в .tres
## скриптом `Tools/convert_content.py`. Спецификация —
## `Docs/Prototype/content-words-v01.md`.

@export_group("Слово")
## Слово из 3–5 латинских букв (UPPER); его буквы появляются в облаке.
@export var word: String = ""

@export_group("Эффект")
## Тип слова: "neutral" / "bad" / "good".
@export var type: String = "neutral"
## Изменение доверия при сборе слова.
@export var trust_effect: int = 0

@export_group("Реакция")
## Кто реагирует: "mom" / "dad" / "both".
@export var speaker: String = ""
## Реплика-реакция на сбор слова (EN).
@export var reaction_text: String = ""
