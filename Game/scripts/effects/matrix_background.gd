class_name MatrixBackground
extends ColorRect
## Полноэкранный фон «Матрица» (этап 2 работы над фоном, 2-я итерация).
##
## Статичная сетка настоящих глифов из атласа; светятся вокруг курсора.
## Заряд набирается от скорости мыши, в покое держится на минимальном полу.
## Шлейф продлевает подсветку по траектории движения.
## В центре — статичное цветовое свечение (не зависит от курсора и глифов).
## Переносит параметры из Configs.matrix в шейдер.
## Умеет плавно приглушаться (режим muted — для меню и диалогов)
## и появляться из темноты (play_appearance — для интро).

## Число точек шлейфа — должно совпадать с TRAIL_POINTS в шейдере.
const TRAIL_POINTS: int = 24

## Приглушённый режим (яркость ниже, чтобы фон не отвлекал).
var muted: bool = false

var _cursor_smooth: Vector2 = Vector2(0.5, 0.5)
var _prev_mouse_uv: Vector2 = Vector2(0.5, 0.5)
var _charge_strength: float = 0.0
var _brightness_current: float = 0.0
## Прогресс появления (анимируется play_appearance()).
var _appear_current: float = 1.0
var _appear_tween: Tween
## Кольцевой буфер шлейфа: позиции в UV и возраст каждой точки в секундах.
var _trail: PackedVector2Array = PackedVector2Array()
var _trail_age: PackedFloat32Array = PackedFloat32Array()
var _trail_idx: int = 0

@onready var _shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	if _shader_material == null:
		push_error("MatrixBackground: у ноды нет ShaderMaterial")
		set_process(false)
		return
	if Configs.matrix == null:
		push_error("MatrixBackground: Configs.matrix не загружен")
		set_process(false)
		return
	_trail.resize(TRAIL_POINTS)
	_trail_age.resize(TRAIL_POINTS)
	for i: int in TRAIL_POINTS:
		_trail[i] = Vector2(0.5, 0.5)
		_trail_age[i] = 10.0
	apply_config()
	# Начальная яркость — сразу в целевую, без перехода из нуля.
	_brightness_current = _target_brightness()


func _process(delta: float) -> void:
	if Configs.matrix == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var mouse_uv: Vector2 = get_global_mouse_position() / viewport_size

	# Общий заряд: набирается от пройденного мышью пути, затухает экспоненциально.
	_charge_strength += mouse_uv.distance_to(_prev_mouse_uv) * Configs.matrix.charge_gain
	_charge_strength = minf(_charge_strength, Configs.matrix.charge_max)
	_charge_strength *= exp(-Configs.matrix.charge_decay_rate * delta)
	_prev_mouse_uv = mouse_uv

	# Шлейф: старим все точки, свежую пишем в кольцевой буфер каждый кадр.
	for i: int in TRAIL_POINTS:
		_trail_age[i] += delta
	_trail[_trail_idx] = mouse_uv
	_trail_age[_trail_idx] = 0.0
	_trail_idx = (_trail_idx + 1) % TRAIL_POINTS

	# Сглаженная позиция курсора (независимо от частоты кадров).
	var smooth_factor: float = 1.0 - exp(-Configs.matrix.cursor_smooth_speed * delta)
	_cursor_smooth = _cursor_smooth.lerp(mouse_uv, smooth_factor)

	# Плавный переход яркости к целевой (обычный/приглушённый режим).
	var brightness_factor: float = 1.0 - exp(-Configs.matrix.brightness_change_speed * delta)
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
	if Configs.matrix == null:
		return
	_kill_appear_tween()
	var duration: float = Configs.matrix.appear_duration
	if duration <= 0.0:
		_appear_current = 1.0
		return
	_appear_current = 0.0
	_appear_tween = create_tween()
	_appear_tween.set_trans(Tween.TRANS_CUBIC)
	_appear_tween.set_ease(Tween.EASE_OUT)
	_appear_tween.tween_property(self, "_appear_current", 1.0, duration)


## Перечитать параметры из Configs.matrix в шейдер (для живых настроек лаборатории).
func apply_config() -> void:
	if _shader_material == null or Configs.matrix == null:
		return
	# Все параметры конфига переносятся в uniform'ы материала один раз при старте
	# и повторно — по вызову из лаборатории фонов.
	_shader_material.set_shader_parameter("cell_size_px", Configs.matrix.cell_size_px)
	_shader_material.set_shader_parameter("glow_radius", Configs.matrix.glow_radius)
	_shader_material.set_shader_parameter("glow_softness", Configs.matrix.glow_softness)
	_shader_material.set_shader_parameter("charge_decay_rate", Configs.matrix.charge_decay_rate)
	_shader_material.set_shader_parameter("charge_boost", Configs.matrix.charge_boost)
	_shader_material.set_shader_parameter("color_glow", Configs.matrix.color_glow)
	_shader_material.set_shader_parameter("color_halo", Configs.matrix.color_halo)
	_shader_material.set_shader_parameter("background_color", Configs.matrix.background_color)
	_shader_material.set_shader_parameter("color_center", Configs.matrix.color_center)
	_shader_material.set_shader_parameter("center_glow_strength", Configs.matrix.center_glow_strength)
	_shader_material.set_shader_parameter("center_glow_radius", Configs.matrix.center_glow_radius)
	_shader_material.set_shader_parameter("charge_floor", Configs.matrix.charge_floor)


func _target_brightness() -> float:
	if Configs.matrix == null:
		return 1.0
	if muted:
		return Configs.matrix.muted_brightness
	return Configs.matrix.brightness


func _update_uniforms(viewport_size: Vector2) -> void:
	_shader_material.set_shader_parameter("trail_points", _trail)
	_shader_material.set_shader_parameter("trail_age", _trail_age)
	_shader_material.set_shader_parameter("cursor_uv", _cursor_smooth)
	_shader_material.set_shader_parameter("charge_strength", _charge_strength)
	_shader_material.set_shader_parameter("brightness", _brightness_current)
	_shader_material.set_shader_parameter("view_size", viewport_size)
	_shader_material.set_shader_parameter("appear", _appear_current)


func _kill_appear_tween() -> void:
	if _appear_tween != null and _appear_tween.is_valid():
		_appear_tween.kill()
	_appear_tween = null
