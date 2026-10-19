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
	_apply_f6_hook()


## Dev-хук визуальной ревизии F6 (только с файлом user://f6_hook.json).
## Файла нет — обычный запуск. Формат: {"state": "VERSION_1", "seed": 7,
## "trust": 0, "window": [1920, 1080], "overlay": "wipe"|"upgrade"|"",
## "upgrade_is_final": false}. В прод-сборке файл не поставляется.
func _apply_f6_hook() -> void:
	if not FileAccess.file_exists("user://f6_hook.json"):
		return
	var raw: String = FileAccess.get_file_as_string("user://f6_hook.json")
	var hook: Dictionary = JSON.parse_string(raw) as Dictionary
	if hook.is_empty():
		push_error("Main: битый user://f6_hook.json")
		return
	if hook.has("seed"):
		seed(int(hook["seed"]))
	if hook.has("window"):
		var w: Array = hook["window"] as Array
		# Окно применяется после первых кадров: рантайм запуска может
		# переопределять размер при старте.
		await get_tree().process_frame
		await get_tree().process_frame
		get_window().size = Vector2i(int(w[0]), int(w[1]))
	Trust.reset()
	if hook.has("trust"):
		Trust.change(int(hook["trust"]) - Trust.get_value())
	if hook.has("upgrade_is_final"):
		Game.upgrade_is_final = bool(hook["upgrade_is_final"])
	if hook.has("state"):
		var target: int = Game.State.get(String(hook["state"]), -1)
		if target >= 0:
			Game.change_state(target as Game.State)
	if hook.has("overlay"):
		match String(hook["overlay"]):
			"wipe":
				_show_scene(WIPE_SCENE)
			"upgrade":
				_show_scene(UPGRADE_SCENE)


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
