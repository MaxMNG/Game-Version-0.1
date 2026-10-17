extends Node
## Шкала «Доверие / Подозрение» людей к ИИ.
##
## Одно число: положительное — доверие, отрицательное — подозрение.
## Игрок никогда не видит точных цифр, только смайлик
## (см. Docs/Systems/trust-suspicion.md).

var _value: int = 0


func _ready() -> void:
	reset()


## Сброс к стартовому значению из конфига (вызывается при новом трае).
func reset() -> void:
	_value = Configs.balance.trust_start_value


## Текущее значение доверия.
func get_value() -> int:
	return _value


## Изменить доверие на дельту. Значение ограничено рамками из конфига.
func change(delta: int) -> void:
	var new_value: int = clampi(
		_value + delta, Configs.balance.trust_min, Configs.balance.trust_max
	)
	var actual_delta: int = new_value - _value
	_value = new_value
	if actual_delta != 0:
		Events.trust_changed.emit(_value, actual_delta)
