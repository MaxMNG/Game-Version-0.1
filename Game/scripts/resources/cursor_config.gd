class_name CursorConfig
extends Resource
## Конфиг игрового курсора (кольцо + точка).
##
## Системный курсор прячется, вместо него рисуется кольцо.
## Над кликабельным (Button) кольцо увеличивается и зеленеет.

@export_group("Размеры")
## Радиус кольца в обычном состоянии (пикселей).
@export var ring_radius: float = 14.0
## Толщина линии кольца.
@export var ring_width: float = 3.0
## Радиус центральной точки.
@export var dot_radius: float = 3.0
## Множитель радиуса кольца при наведении на кликабельное.
@export var hover_scale: float = 1.4

@export_group("Цвета")
## Цвет курсора в обычном состоянии.
@export var color_normal: Color = Color(1, 1, 1, 0.9)
## Цвет курсора над кликабельным элементом.
@export var color_hover: Color = Color(0.4, 1.0, 0.4, 1.0)

@export_group("Ripple")
## Длительность расходящегося круга клика (сек).
@export var ripple_duration: float = 0.35
## Максимальный радиус ripple (пикселей).
@export var ripple_radius: float = 42.0
