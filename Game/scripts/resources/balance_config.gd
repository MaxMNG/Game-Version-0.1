class_name BalanceConfig
extends Resource
## Главный конфиг баланса игры.
##
## Все числа, которые геймдизайнер может захотеть крутить, живут здесь
## (и в других конфигах из resources/configs/). Хардкод в скриптах запрещён.

@export_group("Доверие")
## Стартовое значение доверия в начале трая.
@export var trust_start_value: int = 0
## Минимально возможное значение доверия.
@export var trust_min: int = -5
## Максимально возможное значение доверия.
@export var trust_max: int = 5

@export_group("Стирание")
## Сколько стираний версии допускается за один трай до полного стирания.
@export var wipes_per_run_limit: int = 10

@export_group("Индикатор")
## Сколько секунд видна дельта доверия у смайла.
@export var trust_delta_duration: float = 1.5
