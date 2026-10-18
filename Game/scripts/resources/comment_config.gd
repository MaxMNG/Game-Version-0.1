class_name CommentConfig
extends Resource
## Конфиг системы комментариев (цвета и зоны mom/dad).
##
## Цвета рамок/текста подтягиваются по говорящему.

@export_group("Цвета")
## Цвет мамы (голубоватый бабл).
@export var mom_color: Color = Color(0.55, 0.8, 1.0)
## Цвет папы (оранжево-красный бабл).
@export var dad_color: Color = Color(1.0, 0.55, 0.35)

@export_group("Вид")
## Толщина рамки бабла комментария.
@export var border_width: int = 2
## Скругление углов бабла.
@export var corner_radius: int = 12
## Размер шрифта текста комментария.
@export var font_size: int = 26
