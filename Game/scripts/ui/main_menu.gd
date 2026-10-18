class_name MainMenu
extends Control
## Главное меню + GameIntro (состояние MENU).
##
## Фазы: мигающий квадрат → текст ОС → фейд в фон →
## печать «VERSION » быстро + «0.1» медленно с паузами → кнопка + курсор.

var _phase: int = 0
var _elapsed: float = 0.0
var _logo_shown: int = 0
var _slow_idx: int = 0
var _slow_wait: float = 0.0
var _blink_time: float = 0.0

var _black: ColorRect = null
var _square_label: Label = null
var _os_label: Label = null

@onready var _logo_label: Label = %LogoLabel
@onready var _start_button: Button = %StartButton
@onready var _alpha_label: Label = %AlphaLabel


func _ready() -> void:
	var cfg: MenuConfig = Configs.menu
	_logo_label.text = ""
	_start_button.text = cfg.start_button_text
	_start_button.visible = false
	_alpha_label.text = cfg.alpha_text
	_mute_background(true)
	_set_cursor_visible(false)
	_build_intro_layers()
	_phase = 0
	_elapsed = 0.0


func _build_intro_layers() -> void:
	_black = ColorRect.new()
	_black.name = "IntroBlack"
	_black.set_anchors_preset(Control.PRESET_FULL_RECT)
	_black.color = Color(0, 0, 0, 1)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black)
	_square_label = Label.new()
	_square_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_square_label.offset_top = 16.0
	_square_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Исключение K3: глиф интро ■ — одноразовый размер, в шкалу темы не входит.
	_square_label.add_theme_font_size_override("font_size", 32)
	_square_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_square_label.text = "■"
	add_child(_square_label)
	_os_label = Label.new()
	_os_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_os_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_os_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_os_label.theme_type_variation = &"Body"
	_os_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_os_label.text = ""
	add_child(_os_label)


func _process(delta: float) -> void:
	var cfg: MenuConfig = Configs.menu
	_elapsed += delta
	if _phase == 0:
		_blink_time += delta
		_square_label.visible = fmod(_blink_time, 0.5) < 0.3
		if _elapsed >= cfg.square_duration:
			_phase = 1
			_elapsed = 0.0
			_square_label.visible = false
			_os_label.text = cfg.os_text
	elif _phase == 1:
		if _elapsed >= cfg.os_duration:
			_phase = 2
			_elapsed = 0.0
			_os_label.text = ""
			_mute_background(false)
	elif _phase == 2:
		var tw: Tween = create_tween()
		tw.tween_property(_black, "modulate:a", 0.0, 0.8)
		tw.tween_callback(_on_fade_done)
		_phase = 3
		_elapsed = 0.0
	elif _phase == 4:
		_print_fast(delta)
	elif _phase == 5:
		_print_slow(delta)
	elif _phase == 6:
		if _elapsed >= cfg.button_delay_after_logo:
			_start_button.visible = true
			_set_cursor_visible(true)
			_phase = 7


func _on_fade_done() -> void:
	_black.visible = false
	_phase = 4
	_elapsed = 0.0
	_logo_shown = 0


func _print_fast(delta: float) -> void:
	var cfg: MenuConfig = Configs.menu
	var fast_part: String = "VERSION "
	var want: int = int(_elapsed / cfg.type_interval)
	if want > _logo_shown:
		_logo_shown = mini(want, fast_part.length())
		_logo_label.text = fast_part.left(_logo_shown)
	if _logo_shown >= fast_part.length():
		_phase = 5
		_elapsed = 0.0
		_slow_idx = 0
		_slow_wait = 0.0
	_delta_unused(delta)


func _print_slow(delta: float) -> void:
	var cfg: MenuConfig = Configs.menu
	var slow_part: String = "0.1"
	_slow_wait -= delta
	if _slow_wait > 0.0:
		return
	_elapsed += 0.0
	_slow_idx += 1
	if _slow_idx > slow_part.length():
		_phase = 6
		_elapsed = 0.0
		return
	_logo_label.text = "VERSION " + slow_part.left(_slow_idx)
	_slow_wait = cfg.slow_interval + cfg.slow_pause
	_delta_unused(delta)


func _delta_unused(_delta: float) -> void:
	pass


func _mute_background(muted: bool) -> void:
	var bg: Node = get_tree().get_first_node_in_group("game_background")
	if bg != null and bg.has_method("set_muted"):
		bg.call("set_muted", muted)


func _set_cursor_visible(vis: bool) -> void:
	var cur: Node = get_tree().get_first_node_in_group("game_cursor")
	if cur != null and cur is CanvasItem:
		(cur as CanvasItem).visible = vis


func _on_start_button_pressed() -> void:
	Audio.play_sfx(&"click")
	Trust.reset()
	Game.change_state(Game.State.INTRO)
