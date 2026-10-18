class_name CutsceneConfig
extends Resource
## Конфиг кат-сцен (апгрейды + база: пропуск, подсказка).
##
## Реплики и тайминги сжатия экрана и вспышки.

@export_group("Пропуск")
## Сколько секунд держать SPACE для полного скипа кат-сцены.
@export var skip_hold_duration: float = 2.5
## Подсказка про скип в правом нижнем углу (EN).
@export var skip_hint_text: String = "SPACE (hold) — skip"

@export_group("Тайминги")
## Длительность сжатия экрана в точку (сек).
@export var shrink_duration: float = 0.8
## Длительность вспышки после сжатия (сек).
@export var flash_duration: float = 0.4

@export_group("Апгрейд 0.1 → 0.2")
## Реплики перехода на версию 0.2.
@export var upgrade_lines: Array[DialogueLine] = []

@export_group("Апгрейд 0.2 → 0.3 (финал прототипа)")
## Реплики перехода на заглушку 0.3.
@export var final_lines: Array[DialogueLine] = []
