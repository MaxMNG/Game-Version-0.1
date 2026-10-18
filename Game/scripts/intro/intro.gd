class_name Intro
extends Control
## Интро «Рождение ИИ» (состояние INTRO).
##
## Чёрный экран → вспышка → появление фона → свободная игра с фоном →
## диалог учёных → переход в VERSION_1. Клик/Space пропускает текущий этап.

var _phase: int = 0
var _free_elapsed: float = 0.0

@onready var _flash: FlashOverlay = %FlashOverlay
@onready var _dialogue: DialoguePlayer = %DialoguePlayer


func _ready() -> void:
	# Клики пропускаем в _unhandled_input: корень не должен их съедать.
	mouse_filter = MOUSE_FILTER_IGNORE
	_hide_background()
	_flash.flash_finished.connect(_on_flash_done)
	_dialogue.queue_finished.connect(_on_dialogue_done)
	_flash.flash(Configs.intro.flash_duration)


func _process(delta: float) -> void:
	if _phase == 2:
		_free_elapsed += delta
		if _free_elapsed >= Configs.intro.free_play_duration:
			_phase = 3
			_dialogue.play(Configs.intro.lines)


func _unhandled_input(event: InputEvent) -> void:
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
		_skip_current()


func _skip_current() -> void:
	if _phase == 2:
		_free_elapsed = Configs.intro.free_play_duration
	elif _phase == 3 and _dialogue.is_playing():
		_dialogue.skip_current()


func _hide_background() -> void:
	var bg: Node = get_tree().get_first_node_in_group("game_background")
	if bg != null and bg.has_method("set_reveal"):
		bg.call("set_reveal", 0.0)


func _on_flash_done() -> void:
	_phase = 2
	_free_elapsed = 0.0
	var bg: Node = get_tree().get_first_node_in_group("game_background")
	if bg != null and bg.has_method("play_appearance"):
		bg.call("play_appearance")
	if bg != null and bg.has_method("set_muted"):
		bg.call("set_muted", false)


func _on_dialogue_done() -> void:
	Game.change_state(Game.State.VERSION_1)
