class_name SentenceEntry
extends Resource
## Запись таблицы предложений версии 0.2 (мини-игра «Сбор предложений»).
##
## Источник данных — `Content/sentences_v02.csv`, конвертируется в .tres
## скриптом `Tools/convert_content.py`. Спецификация —
## `Docs/Prototype/content-sentences-v02.md`.

@export_group("Набор")
## Идентификатор набора слов.
@export var set_id: String = ""
## Читаемые слова набора (мусорные глифы добавляет игра).
@export var words: PackedStringArray = PackedStringArray()

@export_group("Предложение")
## Валидное предложение, составляемое из слов набора (EN).
@export var sentence: String = ""
## Тип предложения: "neutral" / "bad" / "good".
@export var type: String = "neutral"
## Изменение доверия при сборе предложения.
@export var trust_effect: int = 0

@export_group("Реакция")
## Кто реагирует: "mom" / "dad" / "both".
@export var speaker: String = ""
## Реплика-реакция на сбор предложения (EN).
@export var reaction_text: String = ""
