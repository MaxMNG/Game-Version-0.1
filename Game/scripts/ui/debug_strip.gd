class_name DebugStrip
extends Label
## Debug-полоска снизу: состояние, Trust-тотал, FPS.
##
## Мелкий полупрозрачный текст, toggle по F3. Точных чисел игрок
## в релизе не увидит — это инструмент прототипа.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	offset_top = -28.0
	offset_bottom = -6.0
	vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_config()


func _apply_config() -> void:
	if Configs.debug == null:
		return
	add_theme_font_size_override("font_size", Configs.debug.font_size)
	add_theme_color_override("font_color", Color(1, 1, 1, Configs.debug.text_opacity))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ke: InputEventKey = event as InputEventKey
		if ke.pressed and not ke.echo and ke.keycode == KEY_F3:
			visible = not visible


func _process(_delta: float) -> void:
	var state_name: String = Game.State.keys()[Game.state]
	var fps: int = int(Engine.get_frames_per_second())
	text = "state=%s trust=%d fps=%d  [F3]" % [state_name, Trust.get_value(), fps]
