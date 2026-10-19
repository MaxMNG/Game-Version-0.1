class_name TrustIndicator
extends HBoxContainer
## Индикатор доверия: смайлик + сегментированная шкала + числа + дельта.
##
## Гайд `03_ui_kit.md`: одна горизонтальная полоска, сегменты, цвет по уровню,
## числа показываем (флаг `show_numbers` в конфиге). Дельта — смайлик + стрелка,
## цвет по направлению (вверх — `good`/`safe`, вниз — `hidden`/`danger`).

var _last_value: int = 0
var _delta_time: float = 0.0

@onready var _face_label: Label = %FaceLabel
@onready var _bar: TrustBar = %TrustBar
@onready var _value_label: Label = %ValueLabel
@onready var _arrow_label: Label = %ArrowLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Events.trust_changed.connect(_on_trust_changed)
	Refresh(Trust.get_value(), 0)


func _process(delta: float) -> void:
	if _delta_time <= 0.0:
		return
	_delta_time -= delta
	if _delta_time <= 0.0:
		_arrow_label.text = ""
	else:
		var total: float = Configs.balance.trust_delta_duration
		var alpha: float = clampf(_delta_time / total, 0.0, 1.0)
		var kept: Color = _arrow_label.modulate
		kept.a = alpha
		_arrow_label.modulate = kept


## Обновить вид по значению и дельте.
func Refresh(value: int, delta: int) -> void:
	_last_value = value
	_face_label.text = _face_for(value)
	_bar.set_bar(Configs.balance.trust_min, Configs.balance.trust_max, value, Configs.balance.trust_bar_segments)
	_value_label.text = "%d%%" % _to_percent(value)
	_value_label.visible = Configs.balance.show_numbers
	if delta > 0:
		_arrow_label.text = "+%d" % delta
		_arrow_label.modulate = Configs.style.col_good
		_delta_time = Configs.balance.trust_delta_duration
	elif delta < 0:
		_arrow_label.text = "%d" % delta
		_arrow_label.modulate = Configs.style.col_danger
		_delta_time = Configs.balance.trust_delta_duration
	else:
		_arrow_label.text = ""
		_delta_time = 0.0


## Смайлик по уровню (5 состояний: очень плохо → очень хорошо).
func _face_for(value: int) -> String:
	var lo: int = Configs.balance.trust_min
	var hi: int = Configs.balance.trust_max
	var frac: float = 0.5
	if hi > lo:
		frac = float(value - lo) / float(hi - lo)
	if frac < 0.2:
		return ">:("
	elif frac < 0.4:
		return ":("
	elif frac < 0.6:
		return ":|"
	elif frac < 0.8:
		return ":)"
	return "XD"


## Значение шкалы в процентах 0–100 для подписи.
func _to_percent(value: int) -> int:
	var lo: int = Configs.balance.trust_min
	var hi: int = Configs.balance.trust_max
	if hi <= lo:
		return 0
	return int(round(float(value - lo) / float(hi - lo) * 100.0))


func _on_trust_changed(new_value: int, delta: int) -> void:
	Refresh(new_value, delta)
