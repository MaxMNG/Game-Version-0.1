extends Node
## Главный автолоад: состояние игры и переходы между состояниями.
##
## Единственная точка, которая решает «что сейчас на экране».
## Сцены не переключаются напрямую — только через Game.change_state().

## Все состояния игры. Порядок совпадает с порядком прохождения.
enum State {
	MENU,       ## Главное меню.
	INTRO,      ## Интро: рождение ИИ.
	VERSION_1,  ## Версия 0.1: сбор слов.
	VERSION_2,  ## Версия 0.2: сбор предложений.
	VERSION_3,  ## Версия 0.3: диалоги (пока не реализуется).
}

## Текущее состояние. Снаружи — только чтение, менять через change_state().
var state: State = State.MENU


## Перевести игру в новое состояние.
func change_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	Events.game_state_changed.emit(new_state)
