class_name Main
extends Control
## Корневая (и единственная базовая) сцена игры.
##
## Слушает смену состояния в автолоаде Game и подменяет содержимое
## контейнера состояний соответствующей сценой (меню, интро, версии...).

## Контейнер, в который загружается сцена текущего состояния.
@onready var _state_container: Control = %StateContainer


func _ready() -> void:
	Events.game_state_changed.connect(_on_game_state_changed)
	# Отрисовываем начальное состояние (главное меню).
	_on_game_state_changed(Game.state)


func _on_game_state_changed(_new_state: Game.State) -> void:
	# Сцены состояний появятся на этапе прототипа (Docs/Prototype/plan.md).
	# Пока контейнер остаётся пустым каркасом.
	pass
