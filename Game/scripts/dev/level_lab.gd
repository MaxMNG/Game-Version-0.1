class_name LevelLab
extends Control
## Dev-сцена «Редактор уровней»: уровень + фон вживую, плавающая панель.
##
## Переключатель Version монтирует мини-игру поверх фона игры в слот.
## Панель — окно поверх геймплея: таскается за шапку, всегда сверху,
## разделы сворачиваются (вкладки), между разделами отступы.
## Save пишет в те же `.tres`, что грузит игра. В игру не входит.

const WORD_SCENE: String = "res://scenes/minigames/word_assembly.tscn"
const SENTENCE_SCENE: String = "res://scenes/minigames/sentence_assembly.tscn"
const BG_SCENE: String = "res://scenes/effects/matrix_smoke_background.tscn"

var _version_id: String = "v01"
var _preview: Control = null
var _background: Control = null
var _dragging: bool = false
var _current_section: VBoxContainer = null

@onready var _slot: Control = %PreviewSlot
@onready var _panel: PanelContainer = %Panel
@onready var _version_option: OptionButton = %VersionOption
@onready var _rows: VBoxContainer = %SettingsRows
@onready var _save_status: Label = %SaveStatus
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_version_option.add_item("Version 0.1", 0)
	_version_option.add_item("Version 0.2", 1)
	_version_option.item_selected.connect(_on_version_selected)
	%SaveButton.pressed.connect(_on_save_pressed)
	%DragHeader.gui_input.connect(_on_header_input)
	_version_option.select(0)
	_mount("v01")


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


## Не дать окну улететь за экран.
func _clamp_panel() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var sz: Vector2 = _panel.get_combined_minimum_size()
	_panel.position.x = clampf(_panel.position.x, 80.0 - sz.x, maxf(80.0 - sz.x, vp.x - 80.0))
	_panel.position.y = clampf(_panel.position.y, 0.0, maxf(0.0, vp.y - 60.0))


func _on_header_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_dragging = true


func _on_version_selected(idx: int) -> void:
	_mount("v01" if idx == 0 else "v02")


func _mount(version_id: String) -> void:
	for child: Node in _slot.get_children():
		child.queue_free()
	_preview = null
	_background = null
	_version_id = version_id
	if ResourceLoader.exists(BG_SCENE):
		_background = (load(BG_SCENE) as PackedScene).instantiate() as Control
		_slot.add_child(_background)
	var path: String = WORD_SCENE if version_id == "v01" else SENTENCE_SCENE
	if not ResourceLoader.exists(path):
		_set_status("Сцены нет: %s" % path)
		return
	_preview = (load(path) as PackedScene).instantiate() as Control
	_slot.add_child(_preview)
	_build_panel()
	_set_status("Сейчас: %s. Всё живое, Save — в .tres." % version_id)


## Живое применение: перечитать визуал мини-игры и фона.
func _apply_live() -> void:
	if _preview != null and _preview.has_method("apply_lab_config"):
		_preview.apply_lab_config()
	if _background != null and _background.has_method("apply_config"):
		_background.apply_config()


func _build_panel() -> void:
	for child: Node in _rows.get_children():
		child.queue_free()
	_save_status.text = ""
	_section("Фон уровня")
	var combo: MatrixSmokeConfig = Configs.matrix_smoke
	if combo != null:
		add_slider("Дым в комбо", 0.0, 1.0, 0.01, combo.smoke_amount,
				func(v: float): combo.smoke_amount = v; _apply_live())
		add_check("Матрица вкл", combo.show_matrix,
				func(v: bool): combo.show_matrix = v; _apply_live())
		add_check("Дым вкл", combo.show_smoke,
				func(v: bool): combo.show_smoke = v; _apply_live())
	if _version_id == "v02":
		var sc: ScanlineConfig = Configs.scanline
		if sc != null:
			add_slider("Сканлайн", 0.0, 0.6, 0.01, sc.intensity,
					func(v: float): sc.intensity = v; _apply_live())
			add_slider("Частота", 60.0, 400.0, 5.0, sc.line_frequency,
					func(v: float): sc.line_frequency = v; _apply_live())
	_section("Облако")
	if _version_id == "v01":
		var v1: Version1Config = Configs.version1
		add_slider("Радиус X", 100.0, 500.0, 5.0, v1.cloud_radius,
				func(v: float): v1.cloud_radius = v; _apply_live())
		add_slider("Радиус Y", 80.0, 400.0, 5.0, v1.cloud_y_radius,
				func(v: float): v1.cloud_y_radius = v; _apply_live())
		add_slider("Сдвиг Y", -400.0, 100.0, 5.0, v1.spawn_offset_y,
				func(v: float): v1.spawn_offset_y = v; _apply_live())
		add_slider("Спавн", 0.0, 0.5, 0.01, v1.spawn_interval,
				func(v: float): v1.spawn_interval = v; _apply_live())
		add_slider("Вращение", 0.0, 1.0, 0.01, v1.cloud_rotation_speed,
				func(v: float): v1.cloud_rotation_speed = v; _apply_live())
		add_slider("Магнит", 0.0, 150.0, 1.0, v1.magnet_pull,
				func(v: float): v1.magnet_pull = v; _apply_live())
		add_slider("Линии", 1.0, 8.0, 0.5, v1.link_width,
				func(v: float): v1.link_width = v; _apply_live())
		add_slider("Мусор мин", 1.0, 20.0, 1.0, float(v1.garbage_min),
				func(v: float): v1.garbage_min = int(v); _apply_live())
		add_slider("Мусор макс", 1.0, 24.0, 1.0, float(v1.garbage_max),
				func(v: float): v1.garbage_max = int(v); _apply_live())
		add_slider("Шрифт", 24.0, 72.0, 1.0, float(v1.symbol_font_size),
				func(v: float): v1.symbol_font_size = int(v); _apply_live())
		_section("Правила и темп")
		add_slider("Слов победа", 1.0, 5.0, 1.0, float(v1.words_to_win),
				func(v: float): v1.words_to_win = int(v); _apply_live())
		add_slider("Реакция", 0.2, 3.0, 0.1, v1.reaction_delay,
				func(v: float): v1.reaction_delay = v; _apply_live())
		add_slider("История", 0.1, 1.0, 0.05, v1.history_opacity,
				func(v: float): v1.history_opacity = v; _apply_live())
	else:
		var v2: Version2Config = Configs.version2
		add_slider("Радиус X", 100.0, 500.0, 5.0, v2.cloud_radius,
				func(v: float): v2.cloud_radius = v; _apply_live())
		add_slider("Радиус Y", 80.0, 400.0, 5.0, v2.cloud_y_radius,
				func(v: float): v2.cloud_y_radius = v; _apply_live())
		add_slider("Сдвиг Y", -400.0, 100.0, 5.0, v2.spawn_offset_y,
				func(v: float): v2.spawn_offset_y = v; _apply_live())
		add_slider("Спавн", 0.0, 0.5, 0.01, v2.spawn_interval,
				func(v: float): v2.spawn_interval = v; _apply_live())
		add_slider("Вращение", 0.0, 1.0, 0.01, v2.cloud_rotation_speed,
				func(v: float): v2.cloud_rotation_speed = v; _apply_live())
		add_slider("Мусора", 0.0, 8.0, 1.0, float(v2.garbage_count),
				func(v: float): v2.garbage_count = int(v); _apply_live())
		add_slider("Шрифт", 16.0, 48.0, 1.0, float(v2.chip_font_size),
				func(v: float): v2.chip_font_size = int(v); _apply_live())
		_section("Правила и темп")
		add_slider("Побед", 1.0, 5.0, 1.0, float(v2.successes_to_win),
				func(v: float): v2.successes_to_win = int(v); _apply_live())
		add_slider("Лимит чуши", 1.0, 10.0, 1.0, float(v2.gibberish_limit),
				func(v: float): v2.gibberish_limit = int(v); _apply_live())
		add_slider("Реакция", 0.2, 3.0, 0.1, v2.reaction_delay,
				func(v: float): v2.reaction_delay = v; _apply_live())
	_section("Комментарии")
	add_color("Мама", Configs.comment.mom_color,
			func(c: Color): Configs.comment.mom_color = c; _apply_live())
	add_color("Папа", Configs.comment.dad_color,
			func(c: Color): Configs.comment.dad_color = c; _apply_live())


## Новый сворачиваемый раздел (вкладка) с отступом.
func _section(title: String) -> void:
	var sep := HSeparator.new()
	_rows.add_child(sep)
	var header := Button.new()
	header.text = "▼ " + title
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	_rows.add_child(header)
	_rows.add_child(body)
	header.pressed.connect(_on_section_toggled.bind(body, header, title))
	_current_section = body


func _on_section_toggled(body: VBoxContainer, header: Button, title: String) -> void:
	body.visible = not body.visible
	header.text = ("▼ " if body.visible else "▶ ") + title


func _target() -> VBoxContainer:
	if _current_section == null:
		_section("Настройки")
	return _current_section


func add_slider(label_text: String, min_v: float, max_v: float, step_v: float,
		initial: float, on_changed: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
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
	_target().add_child(row)


func add_color(label_text: String, initial: Color, on_changed: Callable) -> void:
	var row := HBoxContainer.new()
	var lab := Label.new()
	lab.text = label_text
	lab.custom_minimum_size = Vector2(96, 0)
	var picker := ColorPickerButton.new()
	picker.color = initial
	picker.color_changed.connect(func(c: Color): on_changed.call(c))
	row.add_child(lab)
	row.add_child(picker)
	_target().add_child(row)


func add_check(label_text: String, initial: bool, on_changed: Callable) -> void:
	var check := CheckBox.new()
	check.text = label_text
	check.button_pressed = initial
	check.toggled.connect(func(v: bool): on_changed.call(v))
	_target().add_child(check)


func _on_save_pressed() -> void:
	var targets: Array = [Configs.comment, Configs.matrix_smoke]
	targets.append(Configs.version1 if _version_id == "v01" else Configs.version2)
	if _version_id == "v02":
		targets.append(Configs.scanline)
	for res: Resource in targets:
		if res == null or (res as Resource).resource_path.is_empty():
			continue
		var err: Error = ResourceSaver.save(res, (res as Resource).resource_path)
		if err != OK:
			_save_status.text = "Ошибка: %d" % err
			return
	_save_status.text = "Сохранено."
	_mount(_version_id)


func _set_status(text: String) -> void:
	_status_label.text = text
