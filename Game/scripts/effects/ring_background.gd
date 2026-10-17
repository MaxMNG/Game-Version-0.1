class_name RingBackground
extends ColorRect
## Полноэкранный фон «Кольцо-эквалайзер» (этап 1 работы над фоном).
##
## Переносит параметры из Configs.ring в шейдер, отслеживает мышь:
## сила магнита набирается от скорости движения и экспоненциально затухает.
## Умеет плавно приглушаться (режим muted — для меню и диалогов)
## и появляться из темноты (play_appearance — для интро).

## Приглушённый режим (яркость ниже, чтобы фон не отвлекал).
var muted: bool = false

var _cursor_smooth: Vector2 = Vector2(0.5, 0.5)
var _prev_mouse_uv: Vector2 = Vector2(0.5, 0.5)
var _magnet_strength: float = 0.0
var _brightness_current: float = 0.0
## Прогресс появления (анимируется play_appearance()).
var _appear_current: float = 1.0
var _appear_tween: Tween

@onready var _shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	if _shader_material == null:
		push_error("RingBackground: у ноды нет ShaderMaterial")
		set_process(false)
		return
	if Configs.ring == null:
		push_error("RingBackground: Configs.ring не загружен")
		set_process(false)
		return
	apply_config()
	# Начальная яркость — сразу в целевую, без перехода из нуля.
	_brightness_current = _target_brightness()


func _process(delta: float) -> void:
	if Configs.ring == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var mouse_uv: Vector2 = get_global_mouse_position() / viewport_size

	# Сила магнита: набирается от пройденного мышью пути, затухает экспоненциально.
	_magnet_strength += mouse_uv.distance_to(_prev_mouse_uv) * Configs.ring.magnet_gain
	_magnet_strength = minf(_magnet_strength, Configs.ring.magnet_strength_max)
	_magnet_strength *= exp(-Configs.ring.magnet_decay_rate * delta)
	_prev_mouse_uv = mouse_uv

	# Сглаженная позиция курсора (независимо от частоты кадров).
	var smooth_factor: float = 1.0 - exp(-Configs.ring.cursor_smooth_speed * delta)
	_cursor_smooth = _cursor_smooth.lerp(mouse_uv, smooth_factor)

	# Плавный переход яркости к целевой (обычный/приглушённый режим).
	var brightness_factor: float = 1.0 - exp(-Configs.ring.brightness_change_speed * delta)
	_brightness_current = lerpf(_brightness_current, _target_brightness(), brightness_factor)

	_update_uniforms(viewport_size)


## Включить/выключить приглушённый режим фона.
func set_muted(new_muted: bool) -> void:
	muted = new_muted


## Установить прогресс появления вручную (0 — фон полностью скрыт).
## Гасит активную анимацию появления, если она идёт.
func set_reveal(progress: float) -> void:
	_kill_appear_tween()
	_appear_current = clampf(progress, 0.0, 1.0)


## Появление фона из темноты: прогресс 0 → 1 за appear_duration.
## Для интро: вызывать после вспышки.
func play_appearance() -> void:
	if Configs.ring == null:
		return
	_kill_appear_tween()
	var duration: float = Configs.ring.appear_duration
	if duration <= 0.0:
		_appear_current = 1.0
		return
	_appear_current = 0.0
	_appear_tween = create_tween()
	_appear_tween.set_trans(Tween.TRANS_CUBIC)
	_appear_tween.set_ease(Tween.EASE_OUT)
	_appear_tween.tween_property(self, "_appear_current", 1.0, duration)


## Перечитать параметры из Configs.ring в шейдер (для живых настроек лаборатории).
func apply_config() -> void:
	if _shader_material == null or Configs.ring == null:
		return
	# Все параметры конфига переносятся в uniform'ы материала один раз при старте
	# и повторно — по вызову из лаборатории фонов.
	_shader_material.set_shader_parameter("color_a", Configs.ring.color_a)
	_shader_material.set_shader_parameter("color_b", Configs.ring.color_b)
	_shader_material.set_shader_parameter("color_c", Configs.ring.color_c)
	_shader_material.set_shader_parameter("bar_count", Configs.ring.bar_count)
	_shader_material.set_shader_parameter("ring_radius", Configs.ring.ring_radius)
	_shader_material.set_shader_parameter("bar_base_length", Configs.ring.bar_base_length)
	_shader_material.set_shader_parameter("bar_span", Configs.ring.bar_span)
	_shader_material.set_shader_parameter("bar_width", Configs.ring.bar_width)
	_shader_material.set_shader_parameter("bar_length", Configs.ring.bar_length)
	_shader_material.set_shader_parameter("glow_strength", Configs.ring.glow_strength)
	_shader_material.set_shader_parameter("rotation_speed", Configs.ring.rotation_speed)
	_shader_material.set_shader_parameter("jitter_amount", Configs.ring.jitter_amount)
	_shader_material.set_shader_parameter("jitter_speed", Configs.ring.jitter_speed)
	_shader_material.set_shader_parameter("magnet_radius", Configs.ring.magnet_radius)
	_shader_material.set_shader_parameter("magnet_lift", Configs.ring.magnet_lift)
	_shader_material.set_shader_parameter("magnet_strength_max", Configs.ring.magnet_strength_max)
	_shader_material.set_shader_parameter(
			"magnet_visibility_boost", Configs.ring.magnet_visibility_boost)
	_shader_material.set_shader_parameter("inner_jitter_amount", Configs.ring.inner_jitter_amount)
	_shader_material.set_shader_parameter("inner_jitter_speed", Configs.ring.inner_jitter_speed)
	_shader_material.set_shader_parameter("alpha_min", Configs.ring.alpha_min)
	_shader_material.set_shader_parameter("alpha_speed", Configs.ring.alpha_speed)
	_shader_material.set_shader_parameter("bar_opacity", Configs.ring.bar_opacity)
	_shader_material.set_shader_parameter("gradient_sharp", Configs.ring.gradient_sharp)


func _target_brightness() -> float:
	if Configs.ring == null:
		return 1.0
	if muted:
		return Configs.ring.muted_brightness
	return Configs.ring.brightness


func _update_uniforms(viewport_size: Vector2) -> void:
	_shader_material.set_shader_parameter("cursor_uv", _cursor_smooth)
	_shader_material.set_shader_parameter("magnet_strength", _magnet_strength)
	_shader_material.set_shader_parameter("brightness", _brightness_current)
	_shader_material.set_shader_parameter("aspect", viewport_size.x / viewport_size.y)
	_shader_material.set_shader_parameter("appear", _appear_current)


func _kill_appear_tween() -> void:
	if _appear_tween != null and _appear_tween.is_valid():
		_appear_tween.kill()
	_appear_tween = null
