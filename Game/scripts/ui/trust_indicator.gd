class_name TrustIndicator
extends HBoxContainer
## Индикатор доверия: смайлик + стрелка реакции.
##
## Точных чисел не показывает — только настроение и направление последнего сдвига.
## Слушает Events.trust_changed.

var _last_value: int = 0

@onready var _face_label: Label = %FaceLabel
@onready var _arrow_label: Label = %ArrowLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Events.trust_changed.connect(_on_trust_changed)
	Refresh(Trust.get_value(), 0)


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
		_arrow_label.text = "UP"
	elif delta < 0:
		_arrow_label.text = "DOWN"
	else:
		_arrow_label.text = "--"


func _on_trust_changed(new_value: int, delta: int) -> void:
	Refresh(new_value, delta)
