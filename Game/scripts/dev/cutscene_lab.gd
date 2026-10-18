class_name CutsceneLab
extends Control
## Dev-сцена «Лаборатория кат-сцен»: превью слева, таймлайн справа.
##
## Селектор сцены (интро/апгрейд/стирание), транспорт Play/Stop,
## тайминги слайдерами, реплики списком (спикер/текст/пауза),
## Save пишет в те же `.tres`, что грузит игра. В игру не входит.

const SCENES: Array = [
	{"id": "intro", "title": "Рождение", "scene": "res://scenes/intro/intro.tscn"},
	{"id": "upgrade", "title": "Апгрейд", "scene": "res://scenes/effects/upgrade_cutscene.tscn"},
	{"id": "wipe", "title": "Стирание", "scene": "res://scenes/effects/wipe_screen.tscn"},
]

var _current_id: String = ""
var _current_instance: Control = null
var _editing_lines: Array = []
var _lines_owner: String = ""
var _dragging: bool = false

@onready var _slot: Control = %PreviewSlot
@onready var _panel: PanelContainer = %Panel
@onready var _scene_option: OptionButton = %SceneOption
@onready var _final_check: CheckBox = %FinalCheck
@onready var _save_status: Label = %SaveStatus
@onready var _status_label: Label = %StatusLabel
@onready var _timing_rows: VBoxContainer = %TimingRows
@onready var _lines_list: ItemList = %LinesList
@onready var _speaker_option: OptionButton = %SpeakerOption
@onready var _line_text: TextEdit = %LineText
@onready var _pause_spin: SpinBox = %PauseSpin


func _ready() -> void:
	for i: int in SCENES.size():
		_scene_option.add_item(String(SCENES[i]["title"]), i)
	_scene_option.item_selected.connect(_on_scene_selected)
	_speaker_option.add_item("mom", 0)
	_speaker_option.add_item("dad", 1)
	%PlayButton.pressed.connect(_on_play_pressed)
	%StopButton.pressed.connect(_on_stop_pressed)
	%SaveButton.pressed.connect(_on_save_pressed)
	_final_check.toggled.connect(_on_final_toggled)
	_lines_list.item_selected.connect(_on_line_selected)
	_speaker_option.item_selected.connect(_on_speaker_changed)
	_line_text.text_changed.connect(_on_text_changed)
	_pause_spin.value_changed.connect(_on_pause_changed)
	%AddLine.pressed.connect(_on_add_line)
	%DelLine.pressed.connect(_on_del_line)
	%DragHeader.gui_input.connect(_on_header_input)
	%TmlHeader.pressed.connect(_on_tml_header)
	%LinesHeader.pressed.connect(_on_lines_header)
	_scene_option.select(0)
	_on_scene_selected(0)


func _on_header_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_dragging = true


func _input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_dragging = false
	elif event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		_panel.position += mm.relative
		_clamp_panel()


func _on_tml_header() -> void:
	_timing_rows.visible = not _timing_rows.visible
	%TmlHeader.text = ("▼ Тайминги" if _timing_rows.visible else "▶ Тайминги")


func _on_lines_header() -> void:
	%LinesBody.visible = not %LinesBody.visible
	%LinesHeader.text = ("▼ Реплики (таймлайн)" if %LinesBody.visible else "▶ Реплики (таймлайн)")


## Не дать окну улететь за экран.
func _clamp_panel() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var sz: Vector2 = _panel.get_combined_minimum_size()
	_panel.position.x = clampf(_panel.position.x, 80.0 - sz.x, maxf(80.0 - sz.x, vp.x - 80.0))
	_panel.position.y = clampf(_panel.position.y, 0.0, maxf(0.0, vp.y - 60.0))


func _on_scene_selected(idx: int) -> void:
	_mount(String(SCENES[idx]["id"]))


func _on_final_toggled(_on: bool) -> void:
	if _current_id == "upgrade":
		_mount("upgrade")


func _on_play_pressed() -> void:
	_mount(_current_id)


func _on_stop_pressed() -> void:
	for child: Node in _slot.get_children():
		child.queue_free()
	_current_instance = null
	_set_status("Остановлено.")


func _mount(scene_id: String) -> void:
	for child: Node in _slot.get_children():
		child.queue_free()
	_current_instance = null
	_current_id = scene_id
	if scene_id == "upgrade":
		Game.upgrade_is_final = _final_check.button_pressed
	var path: String = ""
	for entry: Dictionary in SCENES:
		if String(entry["id"]) == scene_id:
			path = String(entry["scene"])
	if not ResourceLoader.exists(path):
		_set_status("Сцены нет: %s" % path)
		return
	var packed: PackedScene = load(path) as PackedScene
	_current_instance = packed.instantiate() as Control
	_slot.add_child(_current_instance)
	_build_timings()
	_build_lines()
	_set_status("Сейчас: %s. Play — перезапуск превью." % scene_id)


func _build_timings() -> void:
	for child: Node in _timing_rows.get_children():
		child.queue_free()
	match _current_id:
		"intro":
			var intro: IntroConfig = Configs.intro
			add_slider("Тьма", 0.5, 5.0, 0.1, intro.black_duration,
					func(v: float): intro.black_duration = v)
			add_slider("Шарик", 1.0, 8.0, 0.1, intro.ball_duration,
					func(v: float): intro.ball_duration = v)
			add_slider("Вспышка", 0.1, 1.5, 0.05, intro.flash_duration,
					func(v: float): intro.flash_duration = v)
		"upgrade":
			var cut: CutsceneConfig = Configs.cutscene
			add_slider("Сжатие", 0.2, 2.0, 0.05, cut.shrink_duration,
					func(v: float): cut.shrink_duration = v)
			add_slider("Вспышка", 0.1, 1.5, 0.05, cut.flash_duration,
					func(v: float): cut.flash_duration = v)
			add_slider("Hold SPACE", 1.0, 5.0, 0.1, cut.skip_hold_duration,
					func(v: float): cut.skip_hold_duration = v)
		"wipe":
			var wipe: WipeConfig = Configs.wipe
			add_slider("Затухание", 0.3, 3.0, 0.1, wipe.fade_duration,
					func(v: float): wipe.fade_duration = v)
			add_slider("Пауза тьмы", 0.0, 2.0, 0.1, wipe.dark_pause,
					func(v: float): wipe.dark_pause = v)


func _lines_array() -> Array:
	match _current_id:
		"intro":
			_lines_owner = "intro"
			return Configs.intro.lines
		"upgrade":
			if Game.upgrade_is_final:
				_lines_owner = "final"
				return Configs.cutscene.final_lines
			_lines_owner = "upgrade"
			return Configs.cutscene.upgrade_lines
		"wipe":
			_lines_owner = "wipe_note"
			return []
	return []


func _build_lines() -> void:
	_lines_list.clear()
	_editing_lines = _lines_array()
	if _current_id == "wipe":
		_lines_list.add_item("dad: %s (из version2.wipe_text)" % Configs.version2.wipe_text)
		_line_text.text = Configs.version2.wipe_text
		return
	for i: int in _editing_lines.size():
		var line: DialogueLine = _editing_lines[i] as DialogueLine
		_lines_list.add_item("%d. %s: %s" % [i + 1, line.speaker_id, line.text])
	if not _editing_lines.is_empty() and not _lines_list.is_selected(0):
		_lines_list.select(0)
		_show_line(0)


func _show_line(idx: int) -> void:
	if idx < 0 or idx >= _editing_lines.size():
		return
	var line: DialogueLine = _editing_lines[idx] as DialogueLine
	_speaker_option.select(0 if String(line.speaker_id) == "mom" else 1)
	_line_text.text = line.text
	_pause_spin.set_value_no_signal(line.pause_after)


func _on_line_selected(idx: int) -> void:
	_show_line(idx)


func _on_speaker_changed(idx: int) -> void:
	var sel: PackedInt32Array = _lines_list.get_selected_items()
	if sel.is_empty():
		return
	var line: DialogueLine = _editing_lines[sel[0]] as DialogueLine
	line.speaker_id = &"mom" if idx == 0 else &"dad"
	_build_lines()
	_lines_list.select(sel[0])


func _on_text_changed() -> void:
	var sel: PackedInt32Array = _lines_list.get_selected_items()
	if sel.is_empty() or _current_id == "wipe":
		return
	var line: DialogueLine = _editing_lines[sel[0]] as DialogueLine
	line.text = _line_text.text
	_lines_list.set_item_text(sel[0], "%d. %s: %s" % [sel[0] + 1, line.speaker_id, line.text])


func _on_pause_changed(v: float) -> void:
	var sel: PackedInt32Array = _lines_list.get_selected_items()
	if sel.is_empty() or _current_id == "wipe":
		return
	(_editing_lines[sel[0]] as DialogueLine).pause_after = v


func _on_add_line() -> void:
	if _current_id == "wipe":
		return
	var line := DialogueLine.new()
	line.speaker_id = &"mom"
	line.text = "New line."
	line.pause_after = Configs.dialogue.default_pause_after
	_editing_lines.append(line)
	_sync_lines_back()
	_build_lines()


func _on_del_line() -> void:
	var sel: PackedInt32Array = _lines_list.get_selected_items()
	if sel.is_empty() or _current_id == "wipe":
		return
	_editing_lines.remove_at(sel[0])
	_sync_lines_back()
	_build_lines()


func _sync_lines_back() -> void:
	match _lines_owner:
		"intro":
			Configs.intro.lines.clear()
			for l: DialogueLine in _editing_lines:
				Configs.intro.lines.append(l)
		"upgrade":
			Configs.cutscene.upgrade_lines.clear()
			for l: DialogueLine in _editing_lines:
				Configs.cutscene.upgrade_lines.append(l)
		"final":
			Configs.cutscene.final_lines.clear()
			for l: DialogueLine in _editing_lines:
				Configs.cutscene.final_lines.append(l)


func _on_save_pressed() -> void:
	_sync_lines_back()
	var targets: Array = []
	match _current_id:
		"intro":
			targets = [Configs.intro]
		"upgrade":
			targets = [Configs.cutscene]
		"wipe":
			targets = [Configs.wipe]
	if _current_id == "wipe":
		Configs.version2.wipe_text = _line_text.text
		targets.append(Configs.version2)
	for res: Resource in targets:
		if res == null or (res as Resource).resource_path.is_empty():
			continue
		var err: Error = ResourceSaver.save(res, (res as Resource).resource_path)
		if err != OK:
			_save_status.text = "Ошибка: %d" % err
			return
	_save_status.text = "Сохранено."
	_set_status("Настройки применятся при следующем Play.")


func add_slider(label_text: String, min_v: float, max_v: float, step_v: float,
		initial: float, on_changed: Callable) -> void:
	var row := HBoxContainer.new()
	row.theme_type_variation = &"TightRow"
	var lab := Label.new()
	lab.text = label_text
	lab.custom_minimum_size = Vector2(96, 0)
	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step_v
	slider.value = initial
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var val := Label.new()
	val.custom_minimum_size = Vector2(48, 0)
	val.text = "%.2f" % initial
	slider.value_changed.connect(func(v: float): val.text = "%.2f" % v; on_changed.call(v))
	row.add_child(lab)
	row.add_child(slider)
	row.add_child(val)
	_timing_rows.add_child(row)


func _set_status(text: String) -> void:
	_status_label.text = text
