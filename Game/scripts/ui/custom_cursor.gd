class_name CustomCursor
extends Control
## Игровой курсор: кольцо + точка вместо системного.
##
## Системный курсор прячется при появлении узла. Кольцо следует за мышью;
## над кликабельным (Button) увеличивается и зеленеет — точно видно,
## куда наводишься. Клики не перехватывает (mouse_filter IGNORE).

var _hover: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	var hovered: Control = get_viewport().gui_get_hovered_control()
	_hover = hovered is Button
	queue_redraw()


func _draw() -> void:
	if Configs.cursor == null:
		return
	var cfg: CursorConfig = Configs.cursor
	var mp: Vector2 = get_global_mouse_position()
	var col: Color = cfg.color_hover if _hover else cfg.color_normal
	var radius: float = cfg.ring_radius * (cfg.hover_scale if _hover else 1.0)
	draw_arc(mp, radius, 0.0, TAU, 32, col, cfg.ring_width, true)
	draw_circle(mp, cfg.dot_radius, col)
