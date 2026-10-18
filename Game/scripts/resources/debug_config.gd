class_name DebugConfig
extends Resource
## Конфиг debug-полоски (тотал Trust и переменные, F3 toggle).
##
## Видна всегда снизу мелким полупрозрачным текстом.

@export_group("Вид")
## Размер шрифта полоски.
@export var font_size: int = 14
## Прозрачность текста (0–1).
@export var text_opacity: float = 0.55
