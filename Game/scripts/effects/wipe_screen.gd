class_name WipeScreen
extends Control
## Экран стирания: затухание, реплика dad, рестарт версии 0.2.
##
## Доверие не сбрасывается — только счётчики мини-игры (новая сцена версии).
## Клик/Space пропускает ожидание.

var _phase: int = 0
var _elapsed: float = 0.0

@onready var _fade: ColorRect = %FadeRect
@onready var _dialogue: DialoguePlayer = %DialoguePlayer


func _ready() -> void:
	# Клики пропускаем в _unhandled_input: корень не должен их съедать.
	mouse_filter = MOUSE_FILTER_IGNORE
	_fade.color = Color(0, 0, 0, 0)
	_fade.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "color:a", 1.0, Configs.wipe.fade_duration)
	tween.tween_callback(_on_fade_done)


func _process(delta: float) -> void:
	if _phase == 1:
		_elapsed += delta
		if _elapsed >= Configs.wipe.dark_pause:
			_finish()


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
		if _dialogue.is_playing():
			_dialogue.skip_current()
		elif _phase == 1:
			_finish()


func _on_fade_done() -> void:
	_phase = 1
	_elapsed = 0.0
	var line := DialogueLine.new()
	line.speaker_id = Game.wipe_speaker
	if Game.wipe_message.is_empty():
		line.text = Configs.version2.wipe_text
	else:
		line.text = Game.wipe_message
	line.pause_after = Configs.dialogue.default_pause_after
	_dialogue.play([line] as Array[DialogueLine])


func _finish() -> void:
	if _phase == 2:
		return
	_phase = 2
	Events.version_restart_requested.emit()
