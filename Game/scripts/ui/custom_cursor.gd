class_name CustomCursor
extends Control
## Игровой курсор: кольцо + точка вместо системного.
##
## Системный курсор прячется при появлении узла. Кольцо следует за мышью;
## над кликабельным (Button) увеличивается и зеленеет — точно видно,
## куда наводишься. Клики не перехватывает (mouse_filter IGNORE).

var _hover: bool = false
var _ripples: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_ripples.append({"pos": get_global_mouse_position(), "age": 0.0})


func _process(delta: float) -> void:
	var hovered: Control = get_viewport().gui_get_hovered_control()
	_hover = hovered is Button
	for i: int in range(_ripples.size() - 1, -1, -1):
		var r: Dictionary = _ripples[i]
		r["age"] = float(r["age"]) + delta
		if float(r["age"]) >= Configs.cursor.ripple_duration:
			_ripples.remove_at(i)
	queue_redraw()


func _draw() -> void:
	if Configs.cursor == null:
		return
	var cfg: CursorConfig = Configs.cursor
	for r: Dictionary in _ripples:
		var t: float = float(r["age"]) / cfg.ripple_duration
		var fade: Color = cfg.color_normal
		fade.a *= 1.0 - t
		draw_arc(r["pos"], cfg.ripple_radius * t, 0.0, TAU, 32, fade, cfg.ring_width, true)
	var mp: Vector2 = get_global_mouse_position()
	var col: Color = cfg.color_hover if _hover else cfg.color_normal
	var radius: float = cfg.ring_radius * (cfg.hover_scale if _hover else 1.0)
	draw_arc(mp, radius, 0.0, TAU, 32, col, cfg.ring_width, true)
	draw_circle(mp, cfg.dot_radius, col)
