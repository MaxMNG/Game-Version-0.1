class_name CommentConfig
extends Resource
## Конфиг системы комментариев (цвета и зоны mom/dad).
##
## Цвета рамок/текста подтягиваются по говорящему.

@export_group("Цвета")
## Цвет мамы (поддержка): семантический `safe` из палитры.
@export var mom_color: Color = Color("#8FD3F4")
## Цвет папы (нейтрально-скептичный): вторичный текст, без ложной тревоги.
@export var dad_color: Color = Color("#73849B")

@export_group("Вид")
## Толщина рамки бабла комментария.
@export var border_width: int = 2
## Скругление углов бабла (0 — квадрат/срез по гайду, скругления запрещены).
@export var corner_radius: int = 0
## Размер шрифта текста комментария.
@export var font_size: int = 26
