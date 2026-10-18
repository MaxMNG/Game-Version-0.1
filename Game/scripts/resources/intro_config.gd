class_name IntroConfig
extends Resource
## Конфиг интро «Рождение ИИ» (состояние INTRO).
##
## Длительность свободной игры с фоном, вспышка и реплики диалога.

@export_group("Тайминги")
## Длительность вспышки в начале интро (сек, звезда).
@export var flash_duration: float = 0.4
## Сколько секунд игрок свободно играет с фоном до диалога (legacy).
@export var free_play_duration: float = 3.0
## Длительность чёрного экрана перед звездой (сек).
@export var black_duration: float = 2.0
## Длительность фазы белого шарика (сек, затем пауза 1с).
@export var ball_duration: float = 4.0
## Размер белого шарика (пикселей).
@export var ball_size: float = 24.0
## Скорость хаотичного движения шарика (пикселей/сек).
@export var ball_speed: float = 260.0

@export_group("Диалог")
## Реплики интро по порядку (mom/dad).
@export var lines: Array[DialogueLine] = []
