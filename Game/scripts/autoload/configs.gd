extends Node
## Точка доступа ко всем конфигурационным ресурсам игры.
##
## Все числовые значения баланса живут в .tres-ресурсах (resources/configs/),
## а не в коде. Скрипты читают их только через этот автолоад.

## Главный конфиг баланса. Загружается один раз при старте игры.
var balance: BalanceConfig


func _ready() -> void:
	balance = load("res://resources/configs/balance.tres") as BalanceConfig
	if balance == null:
		push_error("Configs: не удалось загрузить resources/configs/balance.tres")
