class_name FxSprite
extends Control
## Проигрыватель эффектов Arcada Effector (одна сцена на все эффекты).
##
## Параметры — из `FxConfig` (атлас, fps, размер). Без атласа молчит:
## прячется и сразу сигналит `finished` (атласы подвезёт экспорт из Effector).
## Контракт: `play_once()` / `play_loop()` / `stop()`, сигнал `finished`,
## `mouse_filter = IGNORE`, `set_muted()`.

## Эффект завершён (одно проигрывание доиграло или атласа нет).
signal finished

## Конфиг эффекта (атлас, fps, размер, громкость).
@export var config: FxConfig

@onready var _sprite: AnimatedSprite2D = %FxView


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprite.centered = true
	_reposition()
	resized.connect(_reposition)
	# Стартуем спрятанными: статичный первый кадр атласа не должен
	# светиться до вызова play_once()/play_loop().
	visible = false


## Применить конфиг к спрайту (вызывается и из редактора лабораторий).
## Не показывает: видимость включают только play_once()/play_loop().
func _apply_config() -> void:
	if config == null or config.frames == null:
		return
	_sprite.frames = config.frames
	_fit_to_target()


func _reposition() -> void:
	if is_node_ready():
		_sprite.position = size / 2.0


## Вписать текущий кадр в целевой размер конфига.
func _fit_to_target() -> void:
	if config == null or _sprite.sprite_frames == null:
		return
	if _sprite.sprite_frames.get_frame_count(&"default") <= 0:
		return
	var tex: Texture2D = _sprite.sprite_frames.get_frame_texture(&"default", 0)
	if tex == null:
		return
	var ts: Vector2 = config.target_size
	var fs: Vector2 = Vector2(tex.get_width(), tex.get_height())
	if fs.x <= 0.0 or fs.y <= 0.0:
		return
	var k: float = minf(ts.x / fs.x, ts.y / fs.y)
	_sprite.scale = Vector2(k, k)


## Сыграть один раз; без атласа — сразу `finished`.
func play_once() -> void:
	_apply_config()
	if _sprite.sprite_frames == null or _sprite.sprite_frames.get_frame_count(&"default") <= 0:
		finished.emit()
		return
	visible = true
	_sprite.speed_scale = _speed_scale()
	_sprite.play(&"default")
	await _sprite.animation_finished
	finished.emit()


## Зациклить (фоновая пыль и т.п.).
func play_loop() -> void:
	_apply_config()
	if _sprite.sprite_frames == null or _sprite.sprite_frames.get_frame_count(&"default") <= 0:
		return
	visible = true
	_sprite.speed_scale = _speed_scale()
	_sprite.play(&"default")


## Остановить и спрятать.
func stop() -> void:
	_sprite.stop()
	visible = false


## Приглушить (для меню/диалогов): гасит яркость, не трогая альфу шейдера.
## Здесь эффект — спрайт, поэтому приглушение — через modulate (исключение:
## правило «прозрачность только через альфу» из godot-effect — про шейдерные фоны).
func set_muted(muted: bool) -> void:
	modulate = Color(0.5, 0.5, 0.5, 1.0) if muted else Color(1, 1, 1, 1.0)


func _speed_scale() -> float:
	if config == null:
		return 1.0
	# Базовая скорость анимации в SpriteFrames — 12 fps (см. импортер).
	return config.fps / 12.0
