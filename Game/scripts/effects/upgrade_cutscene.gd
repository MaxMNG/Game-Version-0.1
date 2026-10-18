class_name UpgradeCutscene
extends Control
## Кат-сцена апгрейда: диалог → сжатие экрана в точку → вспышка → переход.
##
## Набор реплик и целевое состояние выбираются по Game.upgrade_is_final:
## false — 0.1 → 0.2, true — 0.2 → 0.3 (заглушка финала прототипа).
## Клик/Space пропускает текущий этап.

var _phase: int = 0

@onready var _flash: FlashOverlay = %FlashOverlay
@onready var _dialogue: DialoguePlayer = %DialoguePlayer
@onready var _shrink_rect: ColorRect = %ShrinkRect


func _ready() -> void:
	# Клики пропускаем в _unhandled_input: корень не должен их съедать.
	mouse_filter = MOUSE_FILTER_IGNORE
	_shrink_rect.visible = false
	_shrink_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialogue.queue_finished.connect(_on_dialogue_done)
	if Game.upgrade_is_final:
		_dialogue.play(Configs.cutscene.final_lines)
	else:
		_dialogue.play(Configs.cutscene.upgrade_lines)
	_phase = 1


func _unhandled_input(event: InputEvent) -> void:
	if _phase != 1:
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
	if advance and _dialogue.is_playing():
		_dialogue.skip_current()


func _on_dialogue_done() -> void:
	_phase = 2
	_play_shrink()


func _play_shrink() -> void:
	_shrink_rect.visible = true
	_shrink_rect.modulate = Color(0, 0, 0, 1)
	_shrink_rect.scale = Vector2.ONE
	_shrink_rect.pivot_offset = get_viewport_rect().size / 2.0
	var tween: Tween = create_tween()
	tween.tween_property(_shrink_rect, "scale", Vector2.ZERO, Configs.cutscene.shrink_duration)
	tween.tween_callback(_on_shrink_done)


func _on_shrink_done() -> void:
	_flash.flash_finished.connect(_on_flash_done)
	_flash.flash(Configs.cutscene.flash_duration)


func _on_flash_done() -> void:
	if Game.upgrade_is_final:
		Game.change_state(Game.State.VERSION_3)
	else:
		Game.change_state(Game.State.VERSION_2)
