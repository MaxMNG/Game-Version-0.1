class_name LevelTitle
extends Label
## Заголовок запуска уровня: печать тем же эффектом, что логотип меню,
## затем уезд вверх в полупрозрачную шапку.

var _full: String = ""
var _shown: int = 0
var _elapsed: float = 0.0
var _done_print: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_CENTER)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 64)


func launch(ver_text: String) -> void:
	_full = ver_text
	_shown = 0
	_elapsed = 0.0
	_done_print = false
	text = ""
	visible = true
	modulate = Color(1, 1, 1, 1)


func _process(delta: float) -> void:
	if _done_print or _full.is_empty():
		return
	_elapsed += delta
	var want: int = int(_elapsed / Configs.menu.type_interval)
	if want > _shown:
		_shown = mini(want, _full.length())
		text = _full.left(_shown)
	if _shown >= _full.length():
		_done_print = true
		_move_to_header()


func _move_to_header() -> void:
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", 16.0, 0.8)
	tw.tween_property(self, "modulate:a", 0.4, 0.8)
	tw.chain().tween_callback(_shrink)


func _shrink() -> void:
	add_theme_font_size_override("font_size", 24)
