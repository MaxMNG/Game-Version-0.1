class_name FloatySymbol
extends Button
## Кликабельный символ облака версии 0.1.
##
## Дрейфует синусоидой вокруг базовой позиции, зелёный — выбран,
## красный — ошибка, белый флеш — успех. Умеет улетать за экран.

## Клик по символу (сам символ).
signal symbol_clicked(symbol: FloatySymbol)

## Глиф символа (один знак).
var glyph: String = ""
## Выбран ли игроком.
var selected: bool = false

var _base_pos: Vector2 = Vector2.ZERO
var _phase: float = 0.0
var _drift_speed: float = 30.0
var _drift_amp: float = 18.0
var _flying: bool = false


func _ready() -> void:
	pressed.connect(_on_pressed)
	toggle_mode = false
	_phase = randf() * TAU


## Настроить символ: глиф, стартовая позиция, параметры дрейфа, шрифт.
func setup(p_glyph: String, start_pos: Vector2, drift_speed: float, drift_amp: float, font_size: int) -> void:
	glyph = p_glyph
	_base_pos = start_pos
	position = start_pos
	_drift_speed = drift_speed
	_drift_amp = drift_amp
	_phase = randf() * TAU
	text = p_glyph
	add_theme_font_size_override("font_size", font_size)
	set_selected(false)


func _process(delta: float) -> void:
	if _flying:
		return
	_phase += delta * _drift_speed / 60.0
	position = _base_pos + Vector2(cos(_phase), sin(_phase * 1.3)) * _drift_amp


## Сдвинуть базовую позицию (вращение облака, магнит).
func set_base_pos(pos: Vector2) -> void:
	_base_pos = pos


## Выделить/снять выделение (зелёное свечение через modulate).
func set_selected(value: bool) -> void:
	selected = value
	if selected:
		modulate = Color(0.4, 1.0, 0.4, 1.0)
	else:
		modulate = Color(1, 1, 1, 1)


## Пометить ошибочным (красный, без мигания — мигание делает сцена).
func set_wrong() -> void:
	modulate = Color(1.0, 0.3, 0.3, 1.0)


## Белый флеш успеха.
func flash_success() -> void:
	modulate = Color(1, 1, 1, 1)


## Улететь за экран с затуханием и удалиться.
func fly_off(direction: Vector2) -> void:
	_flying = true
	var target: Vector2 = position + direction.normalized() * 1400.0
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", target, 0.6)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(queue_free)


## Красное мигание ошибки (совместимость).
func flash_error() -> void:
	set_wrong()


func _on_pressed() -> void:
	symbol_clicked.emit(self)
