class_name PrototypeComplete
extends Control
## Заглушка версии 0.3 — финал прототипа.
##
## Одна надпись из menu.tres. Клик возвращает в главное меню,
## чтобы цикл можно было перетестировать без перезапуска.

@onready var _label: Label = %CompleteLabel


func _ready() -> void:
	# Клики пропускаем в _unhandled_input: корень не должен их съедать.
	mouse_filter = MOUSE_FILTER_IGNORE
	_label.text = Configs.menu.prototype_complete_text


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			Game.change_state(Game.State.MENU)
	if event is InputEventKey:
		var ke: InputEventKey = event as InputEventKey
		if ke.pressed and not ke.echo and (ke.keycode == KEY_SPACE or ke.keycode == KEY_ENTER):
			Game.change_state(Game.State.MENU)
