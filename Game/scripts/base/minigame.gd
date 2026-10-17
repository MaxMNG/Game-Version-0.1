class_name BaseMinigame
extends Control
## Базовый класс всех мини-игр (сбор слов, сбор предложений и т.д.).
##
## Наследники переопределяют _on_started(), _on_succeeded(), _on_failed().
## Жизненный цикл: start() -> succeed() | fail().
## Результат сообщается наружу только через шину Events.

## Идентификатор мини-игры (для логов и сигналов).
@export var minigame_id: StringName = &"base_minigame"

var _is_running: bool = false


## Запустить мини-игру.
func start() -> void:
	if _is_running:
		return
	_is_running = true
	_on_started()


## Завершить успехом.
func succeed() -> void:
	if not _is_running:
		return
	_is_running = false
	Events.minigame_succeeded.emit(minigame_id)
	_on_succeeded()


## Завершить провалом.
func fail() -> void:
	if not _is_running:
		return
	_is_running = false
	Events.minigame_failed.emit(minigame_id)
	_on_failed()


## Вызывается при старте. Переопределить в наследнике.
func _on_started() -> void:
	pass


## Вызывается при успешном завершении. Переопределить в наследнике.
func _on_succeeded() -> void:
	pass


## Вызывается при провале. Переопределить в наследнике.
func _on_failed() -> void:
	pass
