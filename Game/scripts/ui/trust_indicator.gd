class_name TrustIndicator
extends HBoxContainer
## Индикатор доверия: смайлик + всплывающая дельта.
##
## Тотал виден только в debug-полоске; здесь — настроение и дельта
## последнего сдвига, которая затухает. Слушает Events.trust_changed.

var _last_value: int = 0
var _delta_time: float = 0.0

@onready var _face_label: Label = %FaceLabel
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
		_arrow_label.modulate = Color(1, 1, 1, alpha)


## Обновить вид по значению и дельте.
func Refresh(value: int, delta: int) -> void:
	_last_value = value
	if value > 0:
		_face_label.text = ":)"
	elif value < 0:
		_face_label.text = ":("
	else:
		_face_label.text = ":|"
	if delta > 0:
		_arrow_label.text = "+%d" % delta
		_arrow_label.modulate = Color(0.4, 1.0, 0.4, 1.0)
		_delta_time = Configs.balance.trust_delta_duration
	elif delta < 0:
		_arrow_label.text = "%d" % delta
		_arrow_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
		_delta_time = Configs.balance.trust_delta_duration
	else:
		_arrow_label.text = ""
		_delta_time = 0.0


func _on_trust_changed(new_value: int, delta: int) -> void:
	Refresh(new_value, delta)
