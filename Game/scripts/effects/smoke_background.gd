class_name SmokeBackground
extends ColorRect
## Полноэкранный фон «Дымка-lite» (этап 3 работы над фоном).
##
## Переносит параметры из Configs.smoke в шейдер, отслеживает мышь:
## сила возмущения набирается от скорости движения и экспоненциально затухает.
## Гравитация в шейдере стягивает дым к центру, виньетка гасит края.
## Умеет плавно приглушаться (режим muted — для меню и диалогов)
## и появляться из темноты (play_appearance — для интро).

## Лимит октав — должен совпадать с MAX_OCTAVES в шейдере (ограничение GLSL ES).
const MAX_OCTAVES: int = 5

## Приглушённый режим (яркость ниже, чтобы фон не отвлекал).
var muted: bool = false

var _cursor_smooth: Vector2 = Vector2(0.5, 0.5)
var _prev_mouse_uv: Vector2 = Vector2(0.5, 0.5)
var _cursor_strength: float = 0.0
var _brightness_current: float = 0.0
## Прогресс появления (анимируется play_appearance()).
var _appear_current: float = 1.0
var _appear_tween: Tween

@onready var _shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	if _shader_material == null:
		push_error("SmokeBackground: у ноды нет ShaderMaterial")
		set_process(false)
		return
	if Configs.smoke == null:
		push_error("SmokeBackground: Configs.smoke не загружен")
		set_process(false)
		return
	apply_config()
	# Начальная яркость — сразу в целевую, без перехода из нуля.
	_brightness_current = _target_brightness()


func _process(delta: float) -> void:
	if Configs.smoke == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var mouse_uv: Vector2 = get_global_mouse_position() / viewport_size

	# Сила возмущения: набирается от пройденного мышью пути, затухает экспоненциально.
	_cursor_strength += mouse_uv.distance_to(_prev_mouse_uv) * Configs.smoke.cursor_gain
	_cursor_strength = minf(_cursor_strength, Configs.smoke.cursor_strength_max)
	_cursor_strength *= exp(-Configs.smoke.cursor_decay_rate * delta)
	_prev_mouse_uv = mouse_uv

	# Сглаженная позиция курсора (независимо от частоты кадров).
	var smooth_factor: float = 1.0 - exp(-Configs.smoke.cursor_smooth_speed * delta)
	_cursor_smooth = _cursor_smooth.lerp(mouse_uv, smooth_factor)

	# Плавный переход яркости к целевой (обычный/приглушённый режим).
	var brightness_factor: float = 1.0 - exp(-Configs.smoke.brightness_change_speed * delta)
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
	if Configs.smoke == null:
		return
	_kill_appear_tween()
	var duration: float = Configs.smoke.appear_duration
	if duration <= 0.0:
		_appear_current = 1.0
		return
	_appear_current = 0.0
	_appear_tween = create_tween()
	_appear_tween.set_trans(Tween.TRANS_CUBIC)
	_appear_tween.set_ease(Tween.EASE_OUT)
	_appear_tween.tween_property(self, "_appear_current", 1.0, duration)


## Перечитать параметры из Configs.smoke в шейдер (для живых настроек лаборатории).
func apply_config() -> void:
	if _shader_material == null or Configs.smoke == null:
		return
	# Все параметры конфига переносятся в uniform'ы материала один раз при старте
	# и повторно — по вызову из лаборатории фонов.
	_shader_material.set_shader_parameter("background_color", Configs.smoke.background_color)
	_shader_material.set_shader_parameter("layer1_color", Configs.smoke.layer1_color)
	_shader_material.set_shader_parameter("layer2_color", Configs.smoke.layer2_color)
	_shader_material.set_shader_parameter("accent_intensity", Configs.smoke.accent_intensity)
	_shader_material.set_shader_parameter("noise_scale", Configs.smoke.noise_scale)
	_shader_material.set_shader_parameter(
			"octave_count", clampi(Configs.smoke.octave_count, 1, MAX_OCTAVES))
	_shader_material.set_shader_parameter("evolution_speed", Configs.smoke.evolution_speed)
	_shader_material.set_shader_parameter("warp_amount", Configs.smoke.warp_amount)
	_shader_material.set_shader_parameter("noise_contrast", Configs.smoke.noise_contrast)
	_shader_material.set_shader_parameter("gravity_center", Configs.smoke.gravity_center)
	_shader_material.set_shader_parameter("gravity_strength", Configs.smoke.gravity_strength)
	_shader_material.set_shader_parameter("layer1_strength", Configs.smoke.layer1_strength)
	_shader_material.set_shader_parameter("layer2_strength", Configs.smoke.layer2_strength)
	_shader_material.set_shader_parameter("vignette_strength", Configs.smoke.vignette_strength)
	_shader_material.set_shader_parameter("cursor_radius", Configs.smoke.cursor_radius)
	_shader_material.set_shader_parameter("cursor_swirl", Configs.smoke.cursor_swirl)
	# Соло-режим всегда непрозрачный (комбо задаёт свою долю своему материалу).
	_shader_material.set_shader_parameter("amount", 1.0)


func _target_brightness() -> float:
	if Configs.smoke == null:
		return 1.0
	if muted:
		return Configs.smoke.muted_brightness
	return Configs.smoke.brightness


func _update_uniforms(viewport_size: Vector2) -> void:
	_shader_material.set_shader_parameter("cursor_uv", _cursor_smooth)
	_shader_material.set_shader_parameter("cursor_strength", _cursor_strength)
	_shader_material.set_shader_parameter("brightness", _brightness_current)
	_shader_material.set_shader_parameter("aspect", viewport_size.x / viewport_size.y)
	_shader_material.set_shader_parameter("appear", _appear_current)


func _kill_appear_tween() -> void:
	if _appear_tween != null and _appear_tween.is_valid():
		_appear_tween.kill()
	_appear_tween = null
