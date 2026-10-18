class_name MainMenu
extends Control
## Главное меню (состояние MENU).
##
## Печатающийся логотип, кнопка старта, незаметная подпись alpha.
## Фон приглушается через группу game_background.

var _logo_chars: int = 0
var _elapsed: float = 0.0
var _phase: int = 0

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


func _process(delta: float) -> void:
	var cfg: MenuConfig = Configs.menu
	_elapsed += delta
	if _phase == 0:
		if _elapsed < cfg.logo_delay:
			return
		_phase = 1
		_elapsed = 0.0
		_logo_chars = 0
	elif _phase == 1:
		var total: int = cfg.logo_text.length()
		var want: int = int(_elapsed / cfg.type_interval)
		if want > _logo_chars:
			_logo_chars = mini(want, total)
			_logo_label.text = cfg.logo_text.left(_logo_chars)
		if _logo_chars >= total:
			_phase = 2
			_elapsed = 0.0
	elif _phase == 2:
		if _elapsed >= cfg.button_delay_after_logo:
			_start_button.visible = true
			_phase = 3


func _mute_background(muted: bool) -> void:
	var bg: Node = get_tree().get_first_node_in_group("game_background")
	if bg != null and bg.has_method("set_muted"):
		bg.call("set_muted", muted)


func _on_start_button_pressed() -> void:
	Trust.reset()
	Game.change_state(Game.State.INTRO)
