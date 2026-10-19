class_name WipeScreen
extends BaseCutscene
## Экран стирания: затухание, реплика dad, рестарт версии.
##
## Доверие не сбрасывается — только счётчики мини-игры (новая сцена версии).

var _phase: int = 0
var _elapsed: float = 0.0

@onready var _fade: ColorRect = %FadeRect
@onready var _dialogue: DialoguePlayer = %DialoguePlayer
@onready var _fx: FxSprite = %FxLayer


func _ready() -> void:
	super._ready()
	_fade.color = Color(0, 0, 0, 0)
	_fade.visible = true
	_fx.play_once()
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "color:a", 1.0, Configs.wipe.fade_duration)
	tween.tween_callback(_on_fade_done)


func _process(delta: float) -> void:
	if _phase == 1:
		_elapsed += delta
		if _elapsed >= Configs.wipe.dark_pause:
			_finish()


func _advance() -> void:
	if _dialogue.is_playing():
		_dialogue.skip_current()
	elif _phase == 1:
		_finish()


func skip_all() -> void:
	if _is_done:
		return
	_dialogue.stop()
	_finish()
	super.skip_all()


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
