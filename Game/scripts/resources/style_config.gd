class_name StyleConfig
extends Resource
## Конфиг визуального стиля (Диздок `Docs/Design/Style_guide/`).
##
## Все числа/цвета — копия `Configs/style_tokens.json`.
## Код (ChamferPanel, фоны, эффекты) читает их только через `Configs.style`.

@export_group("Цвета: фон и поверхности")
@export var col_void: Color = Color("#05070D")
@export var col_bg: Color = Color("#080D14")
@export var col_bg_deep_blue: Color = Color("#0A1837")
@export var col_surface: Color = Color("#0F1722")
@export var col_surface_2: Color = Color("#182232")
@export var col_line_dim: Color = Color("#242F46")
@export var col_line: Color = Color("#25495F")
@export var col_line_hi: Color = Color("#3A6480")

@export_group("Цвета: синий и текст")
@export var col_blue_deep: Color = Color("#1A5DBA")
@export var col_blue: Color = Color("#2792E0")
@export var col_cyan: Color = Color("#59D0F3")
@export var col_text: Color = Color("#D6E6F2")
@export var col_text_dim: Color = Color("#73849B")
@export var col_text_off: Color = Color("#4A5568")

@export_group("Цвета: семантика")
@export var col_safe: Color = Color("#8FD3F4")
@export var col_good: Color = Color("#2EE6B8")
@export var col_hidden: Color = Color("#9B6BF2")
@export var col_danger: Color = Color("#E83A5C")
@export var col_safe_dim: Color = Color("#2B5565")
@export var col_good_dim: Color = Color("#124D45")
@export var col_hidden_dim: Color = Color("#453C5B")
@export var col_danger_dim: Color = Color("#43213A")

@export_group("Рамка")
## Размер среза угла основной панели (px).
@export var chamfer_size: int = 16
## Размер микросреза мелких элементов (px).
@export var chamfer_size_small: int = 6
## Толщина линии рамки (px).
@export var line_width: int = 2
## Тонкая линия (px).
@export var line_width_thin: int = 1
## Альфа свечения (0–1).
@export var glow_alpha: float = 0.35
## Радиус свечения (px).
@export var glow_radius: int = 12
## Альфа заливки панели (0–1).
@export var panel_fill_alpha: float = 0.72

@export_group("Фон: версия")
## Текущая стадия эволюции фона 1–12 (см. `04_backgrounds.md`).
@export_range(1, 12, 1) var version_stage: int = 1
## Приглушить фон (меню/диалоги).
@export var bg_muted: bool = false
