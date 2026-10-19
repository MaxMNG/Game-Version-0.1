class_name UpgradeCutscene
extends BaseCutscene
## Кат-сцена апгрейда: диалог → сжатие экрана в точку → вспышка → переход.
##
## Набор реплик и целевое состояние выбираются по Game.upgrade_is_final:
## false — 0.1 → 0.2, true — 0.2 → 0.3 (заглушка финала прототипа).
## Клик/Space — шаг диалога, hold SPACE — полный скип (база).

var _phase: int = 0

@onready var _flash: FlashOverlay = %FlashOverlay
@onready var _dialogue: DialoguePlayer = %DialoguePlayer
@onready var _shrink_rect: ColorRect = %ShrinkRect
@onready var _fx: FxSprite = %FxLayer


func _ready() -> void:
	super._ready()
	_shrink_rect.visible = false
	_shrink_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialogue.queue_finished.connect(_on_dialogue_done)
	if Game.upgrade_is_final:
		_dialogue.play(Configs.cutscene.final_lines)
	else:
		_dialogue.play(Configs.cutscene.upgrade_lines)
	_phase = 1


func _advance() -> void:
	if _phase == 1 and _dialogue.is_playing():
		_dialogue.skip_current()


func skip_all() -> void:
	if _is_done:
		return
	_dialogue.stop()
	_on_dialogue_done()
	super.skip_all()


func _on_dialogue_done() -> void:
	if _phase != 1:
		return
	_phase = 2
	_play_shrink()


func _play_shrink() -> void:
	_shrink_rect.visible = true
	_shrink_rect.modulate = Color(0, 0, 0, 1)
	_shrink_rect.scale = Vector2.ONE
	_shrink_rect.pivot_offset = get_viewport_rect().size / 2.0
	_fx.play_once()
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
