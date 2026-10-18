class_name BaseCutscene
extends Control
## Базовый класс кат-сцен (рождение, апгрейды, концовки).
##
## Клик ЛКМ — шаг вперёд, зажатый SPACE — полный скип.
## Во время сцены игровой курсор прячется, в правом нижнем углу —
## подсказка про скип. Наследники переопределяют _play() и _advance().

## Кат-сцена полностью завершена (пора применять следствие).
signal finished

var _hold_time: float = 0.0
var _is_done: bool = false
var _hint: Label = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hint()
	_set_cursor_visible(false)


func _exit_tree() -> void:
	_set_cursor_visible(true)


func _build_hint() -> void:
	_hint = Label.new()
	_hint.name = "SkipHint"
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.offset_left = -420.0
	_hint.offset_top = -40.0
	_hint.offset_right = -16.0
	_hint.offset_bottom = -12.0
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.modulate = Color(1, 1, 1, 0.45)
	_hint.add_theme_font_size_override("font_size", Configs.debug.font_size)
	_hint.text = Configs.cutscene.skip_hint_text
	add_child(_hint)


func _unhandled_input(event: InputEvent) -> void:
	if _is_done:
		return
	var advance: bool = false
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			advance = true
	if event is InputEventKey:
		var ke: InputEventKey = event as InputEventKey
		if ke.pressed and not ke.echo and (ke.keycode == KEY_SPACE or ke.keycode == KEY_ENTER):
			advance = true
	if advance:
		_advance()


func _process(delta: float) -> void:
	if _is_done:
		return
	if Input.is_key_pressed(KEY_SPACE):
		_hold_time += delta
		if _hold_time >= Configs.cutscene.skip_hold_duration:
			skip_all()
	else:
		_hold_time = 0.0


## Шаг вперёд. Переопределить в наследнике.
func _advance() -> void:
	pass


## Полный скип. Переопределить в наследнике (сразу к следствию).
func skip_all() -> void:
	finish()


## Завершить сцену и сообщить наружу.
func finish() -> void:
	if _is_done:
		return
	_is_done = true
	finished.emit()


func _set_cursor_visible(vis: bool) -> void:
	var cur: Node = get_tree().get_first_node_in_group("game_cursor")
	if cur != null and cur is CanvasItem:
		(cur as CanvasItem).visible = vis
