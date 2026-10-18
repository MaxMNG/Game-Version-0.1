class_name Intro
extends BaseCutscene
## Интро «Рождение ИИ» по новому GDD (состояние INTRO).
##
## Маска фейдом в чёрный → 2с тьмы → вспышка-звезда + белый шарик
## (хаос, пульс, маска тает) → пауза 1с → диалог сверху →
## сверхновая (вспышка, маска долой) → VERSION_1.

var _phase: int = 0
var _elapsed: float = 0.0
var _ball_dir: Vector2 = Vector2.RIGHT
var _ball_time: float = 0.0

var _mask: ColorRect = null
var _ball: ColorRect = null

@onready var _flash: FlashOverlay = %FlashOverlay
@onready var _dialogue: DialoguePlayer = %DialoguePlayer


func _ready() -> void:
	super._ready()
	_unmute_background()
	_build_layers()
	_dialogue.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_dialogue.offset_top = 24.0
	_dialogue.offset_bottom = 320.0
	_dialogue.queue_finished.connect(_on_dialogue_done)
	_phase = 0
	_elapsed = 0.0
	_mask.color = Color(0, 0, 0, 0)
	var tw: Tween = create_tween()
	tw.tween_property(_mask, "color:a", 1.0, 0.5)
	tw.tween_callback(_on_mask_black)


func _build_layers() -> void:
	_mask = ColorRect.new()
	_mask.name = "BlackMask"
	_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
	_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mask)
	move_child(_mask, 0)
	_ball = ColorRect.new()
	_ball.name = "WhiteBall"
	_ball.size = Vector2(Configs.intro.ball_size, Configs.intro.ball_size)
	_ball.color = Color(1, 1, 1, 1)
	_ball.visible = false
	_ball.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ball)


func _process(delta: float) -> void:
	super._process(delta)
	if _is_done:
		return
	if _phase == 2 and _ball.visible:
		_ball_time += delta
		if _ball_time > 0.4:
			_ball_time = 0.0
			_ball_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		_ball.position += _ball_dir * Configs.intro.ball_speed * delta
		var vp: Vector2 = get_viewport_rect().size
		_ball.position.x = clampf(_ball.position.x, 0.0, vp.x - _ball.size.x)
		_ball.position.y = clampf(_ball.position.y, 0.0, vp.y - _ball.size.y)
		var pulse: float = 0.7 + 0.3 * sin(Time.get_ticks_msec() / 90.0)
		_ball.modulate = Color(1, 1, 1, pulse)
		_mask.color.a = maxf(0.55, _mask.color.a - delta * 0.08)
	elif _phase == 1 or _phase == 3:
		_elapsed += delta
		if _phase == 1 and _elapsed >= Configs.intro.black_duration:
			_start_ball()
		elif _phase == 3 and _elapsed >= 1.0:
			_start_dialogue()


func _advance() -> void:
	if _phase == 1:
		_elapsed = Configs.intro.black_duration
	elif _phase == 2:
		_finish_ball()
	elif _phase == 3:
		_elapsed = 1.0
	elif _phase == 4 and _dialogue.is_playing():
		_dialogue.skip_current()


func skip_all() -> void:
	if _is_done:
		return
	_dialogue.stop()
	_supernova()
	super.skip_all()


func _on_mask_black() -> void:
	_phase = 1
	_elapsed = 0.0


func _start_ball() -> void:
	_phase = 2
	_ball_time = 0.0
	_ball.position = get_viewport_rect().size / 2.0 - _ball.size / 2.0
	_ball.visible = true
	_flash.flash(Configs.intro.flash_duration)
	Audio.play_sfx(&"click")
	await get_tree().create_timer(Configs.intro.ball_duration).timeout
	if _phase == 2:
		_finish_ball()


func _finish_ball() -> void:
	if _phase != 2:
		return
	_ball.visible = false
	_phase = 3
	_elapsed = 0.0


func _start_dialogue() -> void:
	_phase = 4
	_dialogue.play(Configs.intro.lines)


func _on_dialogue_done() -> void:
	if _phase != 4:
		return
	_supernova()


func _supernova() -> void:
	_phase = 5
	Audio.play_sfx(&"success")
	Audio.start_music(&"v01")
	_shake()
	_flash.flash_finished.connect(_on_flash_done)
	_flash.flash(Configs.intro.flash_duration)


## Тряска экрана в момент сверхновой.
func _shake() -> void:
	var tw: Tween = create_tween()
	for i: int in 6:
		var off: Vector2 = Vector2(randf_range(-14.0, 14.0), randf_range(-14.0, 14.0))
		tw.tween_property(_mask, "position", off, 0.05)
	tw.tween_property(_mask, "position", Vector2.ZERO, 0.05)


func _on_flash_done() -> void:
	_mask.visible = false
	Game.change_state(Game.State.VERSION_1)


func _unmute_background() -> void:
	var bg: Node = get_tree().get_first_node_in_group("game_background")
	if bg != null and bg.has_method("set_muted"):
		bg.call("set_muted", false)
