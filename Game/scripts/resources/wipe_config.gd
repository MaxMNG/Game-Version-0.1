class_name WipeConfig
extends Resource
## Конфиг экрана стирания (провал версии 0.2).
##
## Длительность затухания и реплика; доверие при стирании не сбрасывается.

@export_group("Тайминги")
## Длительность затухания/сброса экрана (сек).
@export var fade_duration: float = 1.2
## Пауза на тёмном экране перед рестартом (сек).
@export var dark_pause: float = 0.8

@export_group("Реплика")
## Кто говорит при стирании.
@export var speaker: String = "dad"
