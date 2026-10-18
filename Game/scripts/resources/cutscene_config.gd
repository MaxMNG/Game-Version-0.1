class_name CutsceneConfig
extends Resource
## Конфиг кат-сцены апгрейда (переходы 0.1 → 0.2 и 0.2 → 0.3-заглушка).
##
## Реплики и тайминги сжатия экрана и вспышки.

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
