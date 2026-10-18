class_name Main
extends Control
## Корневая (и единственная базовая) сцена игры.
##
## Слушает смену состояния в автолоаде Game и подменяет содержимое
## контейнера состояний соответствующей сценой (меню, интро, версии...).
## Оверлеи апгрейда/стирания показываются по сигналам мини-игр без смены стейта.

const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const INTRO_SCENE: PackedScene = preload("res://scenes/intro/intro.tscn")
const WORD_SCENE: PackedScene = preload("res://scenes/minigames/word_assembly.tscn")
const SENTENCE_SCENE: PackedScene = preload("res://scenes/minigames/sentence_assembly.tscn")
const UPGRADE_SCENE: PackedScene = preload("res://scenes/effects/upgrade_cutscene.tscn")
const WIPE_SCENE: PackedScene = preload("res://scenes/effects/wipe_screen.tscn")
const DONE_SCENE: PackedScene = preload("res://scenes/ui/prototype_complete.tscn")

## Контейнер, в который загружается сцена текущего состояния.
@onready var _state_container: Control = %StateContainer
@onready var _background: Control = %Background


func _ready() -> void:
	Events.game_state_changed.connect(_on_game_state_changed)
	Events.version_upgrade_requested.connect(_on_upgrade_requested)
	Events.version_restart_requested.connect(_on_restart_requested)
	Events.minigame_failed.connect(_on_minigame_failed)
	# Отрисовываем начальное состояние (главное меню).
	_on_game_state_changed(Game.state)


func _clear_container() -> void:
	for child: Node in _state_container.get_children():
		_state_container.remove_child(child)
		child.queue_free()


func _show_scene(scene: PackedScene) -> void:
	_clear_container()
	var inst: Node = scene.instantiate()
	_state_container.add_child(inst)


func _set_background_muted(muted: bool) -> void:
	if _background != null and _background.has_method("set_muted"):
		_background.call("set_muted", muted)


func _on_game_state_changed(new_state: Game.State) -> void:
	match new_state:
		Game.State.MENU:
			_set_background_muted(true)
			_show_scene(MENU_SCENE)
		Game.State.INTRO:
			_show_scene(INTRO_SCENE)
		Game.State.VERSION_1:
			_set_background_muted(false)
			_show_scene(WORD_SCENE)
		Game.State.VERSION_2:
			_set_background_muted(false)
			_show_scene(SENTENCE_SCENE)
		Game.State.VERSION_3:
			_set_background_muted(true)
			_show_scene(DONE_SCENE)


func _on_upgrade_requested() -> void:
	_show_scene(UPGRADE_SCENE)


func _on_restart_requested() -> void:
	# Рестарт текущей версии без смены стейта (change_state с тем же
	# значением — no-op, поэтому перевыставляем сцену напрямую).
	match Game.state:
		Game.State.VERSION_2:
			_set_background_muted(false)
			_show_scene(SENTENCE_SCENE)
		Game.State.VERSION_1:
			_set_background_muted(false)
			_show_scene(WORD_SCENE)


func _on_minigame_failed(minigame_id: StringName) -> void:
	if minigame_id == &"sentence_assembly":
		_show_scene(WIPE_SCENE)
