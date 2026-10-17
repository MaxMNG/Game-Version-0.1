class_name BackgroundEffect
extends ColorRect
## Запасной полноэкранный фон (вариант «небула», шаг 1, отложен).
##
## Живой fbm-шум, реагирующий на курсор: сила возмущения набирается
## от скорости движения и экспоненциально затухает.
## Умеет плавно приглушаться (режим muted — для меню и диалогов).
## Эффект сосредоточен в центре экрана: маска проявления гасит картинку
## к краям (reveal_radius/reveal_softness из конфига). Появление «из центра»
## после вспышки (для интро) — через play_appearance().

## Лимит октав — должен совпадать с MAX_OCTAVES в шейдере (ограничение GLSL ES).
const MAX_OCTAVES: int = 5

## Приглушённый режим (яркость ниже, чтобы фон не отвлекал).
var muted: bool = false

var _cursor_smooth: Vector2 = Vector2(0.5, 0.5)
var _prev_mouse_uv: Vector2 = Vector2(0.5, 0.5)
var _cursor_strength: float = 0.0
var _brightness_current: float = 0.0
## Текущий радиус проявления (анимируется play_appearance()).
var _reveal_current: float = 0.6
var _reveal_tween: Tween

@onready var _shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	if _shader_material == null:
		push_error("BackgroundEffect: у ноды нет ShaderMaterial")
		set_process(false)
		return
	if Configs.nebula == null:
		push_error("BackgroundEffect: Configs.nebula не загружен")
		set_process(false)
		return
	_apply_config()
	# Начальная яркость — сразу в целевую, без перехода из нуля.
	_brightness_current = _target_brightness()


func _process(delta: float) -> void:
	if Configs.nebula == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var mouse_uv: Vector2 = get_global_mouse_position() / viewport_size

	# Сила возмущения: набирается от пройденного мышью пути, затухает экспоненциально.
	_cursor_strength += mouse_uv.distance_to(_prev_mouse_uv) * Configs.nebula.cursor_gain
	_cursor_strength = minf(_cursor_strength, Configs.nebula.cursor_strength_max)
	_cursor_strength *= exp(-Configs.nebula.cursor_decay_rate * delta)
	_prev_mouse_uv = mouse_uv

	# Сглаженная позиция курсора (независимо от частоты кадров).
	var smooth_factor: float = 1.0 - exp(-Configs.nebula.cursor_smooth_speed * delta)
	_cursor_smooth = _cursor_smooth.lerp(mouse_uv, smooth_factor)

	# Плавный переход яркости к целевой (обычный/приглушённый режим).
	var brightness_factor: float = 1.0 - exp(-Configs.nebula.brightness_change_speed * delta)
	_brightness_current = lerpf(_brightness_current, _target_brightness(), brightness_factor)

	_update_uniforms(viewport_size)


## Включить/выключить приглушённый режим фона.
func set_muted(new_muted: bool) -> void:
	muted = new_muted


## Установить радиус проявления вручную (0 — фон полностью скрыт).
## Гасит активную анимацию появления, если она идёт.
func set_reveal(radius: float) -> void:
	_kill_reveal_tween()
	_reveal_current = maxf(radius, 0.0)


## Проявление фона из центра: радиус 0 → полный, за reveal_appear_duration.
## Для интро: вызывать после вспышки.
func play_appearance() -> void:
	if Configs.nebula == null:
		return
	_kill_reveal_tween()
	var duration: float = Configs.nebula.reveal_appear_duration
	if duration <= 0.0:
		_reveal_current = Configs.nebula.reveal_radius
		return
	_reveal_current = 0.0
	_reveal_tween = create_tween()
	_reveal_tween.set_trans(Tween.TRANS_CUBIC)
	_reveal_tween.set_ease(Tween.EASE_OUT)
	_reveal_tween.tween_property(
			self, "_reveal_current", Configs.nebula.reveal_radius, duration)


func _target_brightness() -> float:
	if Configs.nebula == null:
		return 1.0
	if muted:
		return Configs.nebula.muted_brightness
	return Configs.nebula.brightness


func _apply_config() -> void:
	# Все параметры конфига переносятся в uniform'ы материала один раз при старте.
	_shader_material.set_shader_parameter("background_color", Configs.nebula.background_color)
	_shader_material.set_shader_parameter("purple_color", Configs.nebula.purple_color)
	_shader_material.set_shader_parameter("magenta_color", Configs.nebula.magenta_color)
	_shader_material.set_shader_parameter("green_color", Configs.nebula.green_color)
	_shader_material.set_shader_parameter("accent_intensity", Configs.nebula.accent_intensity)
	_shader_material.set_shader_parameter("noise_scale", Configs.nebula.noise_scale)
	_shader_material.set_shader_parameter(
			"octave_count", clampi(Configs.nebula.octave_count, 1, MAX_OCTAVES))
	_shader_material.set_shader_parameter("evolution_speed", Configs.nebula.evolution_speed)
	_shader_material.set_shader_parameter("warp_amount", Configs.nebula.warp_amount)
	_shader_material.set_shader_parameter("noise_contrast", Configs.nebula.noise_contrast)
	_shader_material.set_shader_parameter("green_anchor", Configs.nebula.green_anchor)
	_shader_material.set_shader_parameter("green_radius", Configs.nebula.green_radius)
	_shader_material.set_shader_parameter("layer1_strength", Configs.nebula.layer1_strength)
	_shader_material.set_shader_parameter("layer2_strength", Configs.nebula.layer2_strength)
	_shader_material.set_shader_parameter("vignette_strength", Configs.nebula.vignette_strength)
	_shader_material.set_shader_parameter("cursor_radius", Configs.nebula.cursor_radius)
	_shader_material.set_shader_parameter("cursor_swirl", Configs.nebula.cursor_swirl)
	_shader_material.set_shader_parameter("reveal_center", Configs.nebula.reveal_center)
	_shader_material.set_shader_parameter("reveal_softness", Configs.nebula.reveal_softness)
	_reveal_current = Configs.nebula.reveal_radius


func _update_uniforms(viewport_size: Vector2) -> void:
	_shader_material.set_shader_parameter("cursor_uv", _cursor_smooth)
	_shader_material.set_shader_parameter("cursor_strength", _cursor_strength)
	_shader_material.set_shader_parameter("brightness", _brightness_current)
	_shader_material.set_shader_parameter("aspect", viewport_size.x / viewport_size.y)
	_shader_material.set_shader_parameter("reveal_radius", _reveal_current)


func _kill_reveal_tween() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_reveal_tween = null
