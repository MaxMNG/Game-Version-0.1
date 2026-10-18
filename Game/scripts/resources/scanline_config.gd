class_name ScanlineConfig
extends Resource
## Конфиг слоя scanlines/ripple для версии 0.2 (сине-голубой).

@export_group("Вид")
## Цвет линий.
@export var line_color: Color = Color(0.35, 0.65, 1.0)
## Интенсивность (прозрачность слоя, 0–1).
@export var intensity: float = 0.18
## Частота полос по вертикали.
@export var line_frequency: float = 220.0
## Скорость бегущей ряби.
@export var ripple_speed: float = 1.6
