class_name FloatySymbol
extends Button
## Кликабельный символ облака версии 0.1.
##
## Медленно дрейфует синусоидой, выделяется зелёным, ошибка — красное мигание.

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
	_phase += delta * _drift_speed / 60.0
	position = _base_pos + Vector2(cos(_phase), sin(_phase * 1.3)) * _drift_amp


## Выделить/снять выделение (зелёное свечение через modulate).
func set_selected(value: bool) -> void:
	selected = value
	if selected:
		modulate = Color(0.4, 1.0, 0.4, 1.0)
	else:
		modulate = Color(1, 1, 1, 1)


## Красное мигание ошибки.
func flash_error() -> void:
	var tween: Tween = create_tween()
	modulate = Color(1.0, 0.3, 0.3, 1.0)
	tween.tween_property(self, "modulate:a", 0.2, 0.15)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	tween.tween_callback(_restore_after_flash)


func _restore_after_flash() -> void:
	set_selected(selected)


func _on_pressed() -> void:
	symbol_clicked.emit(self)
