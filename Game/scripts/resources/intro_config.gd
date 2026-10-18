class_name IntroConfig
extends Resource
## Конфиг интро «Рождение ИИ» (состояние INTRO).
##
## Длительность свободной игры с фоном, вспышка и реплики диалога.

@export_group("Тайминги")
## Длительность вспышки в начале интро (сек).
@export var flash_duration: float = 0.4
## Сколько секунд игрок свободно играет с фоном до диалога.
@export var free_play_duration: float = 3.0

@export_group("Диалог")
## Реплики интро по порядку (mom/dad).
@export var lines: Array[DialogueLine] = []
