class_name BackgroundLab
extends Control
## Dev-сцена «Background Lab»: сравнение вариантов фона вживую.
##
## Слот во весь экран + 3 кнопки переключения + панель живых настроек
## активного эффекта + кнопка Save (запись подобранного в .tres).
## В игру не входит, запускается отдельно. Числа баланса не хранит —
## всё пишет напрямую в ресурсы конфигов (Configs.ring и т.д.).

## Кнопки: порядок и сцены эффектов. Сцены этапов 2–3 появятся позже —
## кнопки таких эффектов честно говорят «ещё не готов».
const EFFECTS: Array = [
	{"id": "ring", "title": "Кольцо", "scene": "res://scenes/effects/ring_background.tscn"},
	{"id": "matrix", "title": "Матрица", "scene": "res://scenes/effects/matrix_background.tscn"},
	{"id": "smoke", "title": "Дымка", "scene": "res://scenes/effects/smoke_background.tscn"},
	{"id": "combo", "title": "Комбо", "scene": "res://scenes/effects/matrix_smoke_background.tscn"},
]

## Запасной вариант, смонтирован пока эффекты не готовы.
const FALLBACK_TITLE: String = "Небула (запас)"
const FALLBACK_SCENE: String = "res://scenes/effects/background_effect.tscn"

var _current_id: String = ""
var _current_instance: Control = null
var _current_config: Resource = null
var _dragging: bool = false
var _current_section: VBoxContainer = null

@onready var _slot: Control = %BackgroundSlot
@onready var _panel: PanelContainer = %SidePanel
@onready var _rows: VBoxContainer = %SettingsRows
@onready var _save_button: Button = %SaveButton
@onready var _save_status: Label = %SaveStatus
@onready var _status_label: Label = %StatusLabel
@onready var _btn_ring: Button = %BtnRing
@onready var _btn_matrix: Button = %BtnMatrix
@onready var _btn_smoke: Button = %BtnSmoke
@onready var _btn_combo: Button = %BtnCombo


func _ready() -> void:
	_btn_ring.pressed.connect(_on_effect_button.bind("ring"))
	_btn_matrix.pressed.connect(_on_effect_button.bind("matrix"))
	_btn_smoke.pressed.connect(_on_effect_button.bind("smoke"))
	_btn_combo.pressed.connect(_on_effect_button.bind("combo"))
	_save_button.pressed.connect(_on_save_pressed)
	%DragHeader.gui_input.connect(_on_header_input)
	# Стартуем с самого нового готового эффекта, иначе — запасной вариант.
	if ResourceLoader.exists(EFFECTS[0]["scene"]):
		_on_effect_button(EFFECTS[0]["id"])
	else:
		_mount_fallback()


func _on_effect_button(effect_id: String) -> void:
	var entry: Dictionary = _find_entry(effect_id)
	if entry.is_empty():
		return
	if not ResourceLoader.exists(entry["scene"]):
		_set_status("«%s» ещё не готов." % entry["title"])
		return
	_mount(entry)


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


## Не дать окну улететь за экран.
func _clamp_panel() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var sz: Vector2 = _panel.get_combined_minimum_size()
	_panel.position.x = clampf(_panel.position.x, 80.0 - sz.x, maxf(80.0 - sz.x, vp.x - 80.0))
	_panel.position.y = clampf(_panel.position.y, 0.0, maxf(0.0, vp.y - 60.0))


## Новый сворачиваемый раздел (вкладка) с отступом.
func _section(title: String) -> void:
	var sep := HSeparator.new()
	_rows.add_child(sep)
	var header := Button.new()
	header.text = "▼ " + title
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.theme_type_variation = &"TightStack"
	_rows.add_child(header)
	_rows.add_child(body)
	header.pressed.connect(_on_section_toggled.bind(body, header, title))
	_current_section = body


func _on_section_toggled(body: VBoxContainer, header: Button, title: String) -> void:
	body.visible = not body.visible
	header.text = ("▼ " if body.visible else "▶ ") + title


func _target() -> VBoxContainer:
	if _current_section == null or not is_instance_valid(_current_section):
		return _rows
	return _current_section
func _on_save_pressed() -> void:
	if _current_config == null or _current_config.resource_path.is_empty():
		_save_status.text = "Нечего сохранять."
		return
	var error: Error = ResourceSaver.save(_current_config, _current_config.resource_path)
	if error == OK:
		_save_status.text = "Сохранено."
	else:
		_save_status.text = "Ошибка сохранения: %d" % error


## Добавить в панель строку-слайдер (для живых настроек эффекта).
func add_slider(label_text: String, min_v: float, max_v: float, step_v: float,
		initial: float, on_changed: Callable) -> void:
	var row := HBoxContainer.new()
	row.theme_type_variation = &"TightRow"
	row.custom_minimum_size = Vector2(0, 32)
	var lab := Label.new()
	lab.text = label_text
	lab.theme_type_variation = &"Caption"
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.custom_minimum_size = Vector2(118, 0)
	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step_v
	slider.value = initial
	slider.custom_minimum_size = Vector2(0, 28)
	slider.focus_mode = Control.FOCUS_ALL
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var val := Label.new()
	val.custom_minimum_size = Vector2(52, 0)
	val.theme_type_variation = &"Caption"
	val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	val.text = _format_value(initial, step_v)
	slider.value_changed.connect(_on_slider_changed.bind(val, step_v, on_changed))
	row.add_child(lab)
	row.add_child(slider)
	row.add_child(val)
	_target().add_child(row)


## Добавить в панель строку-выбор цвета (для живых настроек эффекта).
func add_color(label_text: String, initial: Color, on_changed: Callable) -> void:
	var row := HBoxContainer.new()
	row.theme_type_variation = &"TightRow"
	row.custom_minimum_size = Vector2(0, 32)
	var lab := Label.new()
	lab.text = label_text
	lab.theme_type_variation = &"Caption"
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.custom_minimum_size = Vector2(118, 0)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var picker := ColorPickerButton.new()
	picker.color = initial
	picker.custom_minimum_size = Vector2(64, 0)
	picker.color_changed.connect(func(c: Color): on_changed.call(c))
	row.add_child(lab)
	row.add_child(picker)
	_target().add_child(row)


## Очистить панель настроек.
func clear_panel() -> void:
	_current_section = null
	for child: Node in _rows.get_children():
		child.queue_free()
	_save_status.text = ""


func _find_entry(effect_id: String) -> Dictionary:
	for entry: Dictionary in EFFECTS:
		if entry["id"] == effect_id:
			return entry
	return {}


func _mount(entry: Dictionary) -> void:
	_clear_slot()
	var packed: PackedScene = load(entry["scene"]) as PackedScene
	if packed == null:
		_set_status("Не загрузилась сцена «%s»." % entry["title"])
		return
	_current_instance = packed.instantiate() as Control
	if _current_instance == null:
		_set_status("Сцена «%s» — не Control." % entry["title"])
		return
	_slot.add_child(_current_instance)
	_current_id = entry["id"]
	_current_config = _config_for(_current_id)
	_build_panel()
	_set_status("Сейчас: %s." % entry["title"])


func _mount_fallback() -> void:
	_clear_slot()
	var packed: PackedScene = load(FALLBACK_SCENE) as PackedScene
	if packed == null:
		_set_status("Нет ни эффектов, ни запасного варианта.")
		return
	_current_instance = packed.instantiate() as Control
	_slot.add_child(_current_instance)
	_current_id = "nebula"
	_current_config = null
	clear_panel()
	var lab := Label.new()
	lab.text = "Запасной вариант.\nНастройки — с новыми\nэффектами."
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_target().add_child(lab)
	_set_status("Сейчас: %s." % FALLBACK_TITLE)


func _clear_slot() -> void:
	for child: Node in _slot.get_children():
		child.queue_free()
	_current_instance = null
	_current_config = null
	_current_id = ""


func _config_for(effect_id: String) -> Resource:
	match effect_id:
		"ring":
			return Configs.ring
		"matrix":
			return Configs.matrix
		"smoke":
			return Configs.smoke
		"combo":
			return Configs.matrix_smoke
	return null


func _build_panel() -> void:
	clear_panel()
	match _current_id:
		"ring":
			_build_ring_panel()
		"matrix":
			_build_matrix_panel()
		"smoke":
			_build_smoke_panel()
		"combo":
			_build_combo_panel()
		_:
			var lab := Label.new()
			lab.text = "Нет настроек."
			_rows.add_child(lab)


func _build_ring_panel() -> void:
	var ring: RingConfig = Configs.ring
	if ring == null:
		return
	_section("Геометрия и динамика")
	add_slider("Бары", 32.0, 256.0, 1.0, ring.bar_count,
			func(v: float): ring.bar_count = int(v); _apply_current())
	add_slider("Радиус", 0.15, 0.5, 0.01, ring.ring_radius,
			func(v: float): ring.ring_radius = v; _apply_current())
	add_slider("Дрожание", 0.0, 1.0, 0.01, ring.jitter_amount,
			func(v: float): ring.jitter_amount = v; _apply_current())
	add_slider("Магнетизм", 0.0, 2.0, 0.01, ring.magnet_strength_max,
			func(v: float): ring.magnet_strength_max = v; _apply_current())
	add_slider("Радиус магн.", 0.05, 0.5, 0.01, ring.magnet_radius,
			func(v: float): ring.magnet_radius = v; _apply_current())
	add_slider("Свечение", 0.0, 1.5, 0.01, ring.glow_strength,
			func(v: float): ring.glow_strength = v; _apply_current())
	add_slider("Внутр. гран.", 0.0, 1.5, 0.01, ring.inner_jitter_amount,
			func(v: float): ring.inner_jitter_amount = v; _apply_current())
	add_slider("Прозрачн.", 0.0, 1.0, 0.01, ring.alpha_min,
			func(v: float): ring.alpha_min = v; _apply_current())
	add_slider("Резкость", 0.5, 4.0, 0.01, ring.gradient_sharp,
			func(v: float): ring.gradient_sharp = v; _apply_current())
	add_slider("Заметн. +", 0.0, 1.5, 0.01, ring.magnet_visibility_boost,
			func(v: float): ring.magnet_visibility_boost = v; _apply_current())
	add_slider("Длина", 0.0, 100.0, 1.0, ring.bar_length,
			func(v: float): ring.bar_length = v; _apply_current())
	add_slider("Альфа", 0.0, 1.0, 0.01, ring.bar_opacity,
			func(v: float): ring.bar_opacity = v; _apply_current())
	_section("Цвета")
	add_color("Цвет A", ring.color_a,
			func(c: Color): ring.color_a = c; _apply_current())
	add_color("Цвет B", ring.color_b,
			func(c: Color): ring.color_b = c; _apply_current())
	add_color("Цвет C", ring.color_c,
			func(c: Color): ring.color_c = c; _apply_current())


func _build_matrix_panel() -> void:
	var matrix: MatrixConfig = Configs.matrix
	if matrix == null:
		return
	_section("Сетка и заряд")
	add_slider("Ячейка", 8.0, 32.0, 8.0, matrix.cell_size_px,
			func(v: float): matrix.cell_size_px = v; _apply_current())
	add_slider("Радиус", 0.05, 0.4, 0.01, matrix.glow_radius,
			func(v: float): matrix.glow_radius = v; _apply_current())
	add_slider("Мягкость", 0.5, 5.0, 0.1, matrix.glow_softness,
			func(v: float): matrix.glow_softness = v; _apply_current())
	add_slider("Набор", 1.0, 30.0, 0.5, matrix.charge_gain,
			func(v: float): matrix.charge_gain = v; _apply_current())
	add_slider("Макс. заряд", 0.2, 3.0, 0.1, matrix.charge_max,
			func(v: float): matrix.charge_max = v; _apply_current())
	add_slider("Усиление", 0.0, 3.0, 0.05, matrix.charge_boost,
			func(v: float): matrix.charge_boost = v; _apply_current())
	add_slider("Затухание", 0.2, 5.0, 0.1, matrix.charge_decay_rate,
			func(v: float): matrix.charge_decay_rate = v; _apply_current())
	add_slider("Мин. заряд", 0.0, 0.5, 0.01, matrix.charge_floor,
			func(v: float): matrix.charge_floor = v; _apply_current())
	add_slider("Центр сила", 0.0, 1.0, 0.05, matrix.center_glow_strength,
			func(v: float): matrix.center_glow_strength = v; _apply_current())
	add_slider("Центр радиус", 0.1, 0.8, 0.05, matrix.center_glow_radius,
			func(v: float): matrix.center_glow_radius = v; _apply_current())
	add_slider("Сглажив.", 1.0, 20.0, 0.5, matrix.cursor_smooth_speed,
			func(v: float): matrix.cursor_smooth_speed = v; _apply_current())
	add_slider("Яркость", 0.1, 1.5, 0.05, matrix.brightness,
			func(v: float): matrix.brightness = v; _apply_current())
	_section("Цвета")
	add_color("Свечение", matrix.color_glow,
			func(c: Color): matrix.color_glow = c; _apply_current())
	add_color("Ореол", matrix.color_halo,
			func(c: Color): matrix.color_halo = c; _apply_current())
	add_color("Центр", matrix.color_center,
			func(c: Color): matrix.color_center = c; _apply_current())
	add_color("Фон", matrix.background_color,
			func(c: Color): matrix.background_color = c; _apply_current())


func _build_smoke_panel() -> void:
	var smoke: SmokeConfig = Configs.smoke
	if smoke == null:
		return
	_section("Шум и динамика")
	add_slider("Масштаб", 1.5, 6.0, 0.1, smoke.noise_scale,
			func(v: float): smoke.noise_scale = v; _apply_current())
	add_slider("Октавы", 1.0, 4.0, 1.0, float(smoke.octave_count),
			func(v: float): smoke.octave_count = int(v); _apply_current())
	add_slider("Эволюция", 0.0, 0.3, 0.01, smoke.evolution_speed,
			func(v: float): smoke.evolution_speed = v; _apply_current())
	add_slider("Варп", 0.0, 1.5, 0.05, smoke.warp_amount,
			func(v: float): smoke.warp_amount = v; _apply_current())
	add_slider("Контраст", 1.0, 4.0, 0.1, smoke.noise_contrast,
			func(v: float): smoke.noise_contrast = v; _apply_current())
	add_slider("Гравитация", 0.0, 1.0, 0.05, smoke.gravity_strength,
			func(v: float): smoke.gravity_strength = v; _apply_current())
	add_slider("Слой 1", 0.0, 1.0, 0.05, smoke.layer1_strength,
			func(v: float): smoke.layer1_strength = v; _apply_current())
	add_slider("Слой 2", 0.0, 1.0, 0.05, smoke.layer2_strength,
			func(v: float): smoke.layer2_strength = v; _apply_current())
	add_slider("Интенсивн.", 0.0, 1.0, 0.05, smoke.accent_intensity,
			func(v: float): smoke.accent_intensity = v; _apply_current())
	add_slider("Виньетка", 0.0, 1.0, 0.05, smoke.vignette_strength,
			func(v: float): smoke.vignette_strength = v; _apply_current())
	add_slider("Радиус курс.", 0.05, 0.5, 0.01, smoke.cursor_radius,
			func(v: float): smoke.cursor_radius = v; _apply_current())
	add_slider("Завихрение", 0.0, 1.5, 0.05, smoke.cursor_swirl,
			func(v: float): smoke.cursor_swirl = v; _apply_current())
	add_slider("Яркость", 0.1, 1.5, 0.05, smoke.brightness,
			func(v: float): smoke.brightness = v; _apply_current())
	_section("Цвета")
	add_color("Фон", smoke.background_color,
			func(c: Color): smoke.background_color = c; _apply_current())
	add_color("Слой 1", smoke.layer1_color,
			func(c: Color): smoke.layer1_color = c; _apply_current())
	add_color("Слой 2", smoke.layer2_color,
			func(c: Color): smoke.layer2_color = c; _apply_current())


func _build_combo_panel() -> void:
	var combo: MatrixSmokeConfig = Configs.matrix_smoke
	if combo == null:
		return
	var hint := Label.new()
	hint.text = "Матрица снизу, дым сверху.\nСлои настраиваются\nна вкладках 2 и 3."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_target().add_child(hint)
	add_slider("Дым в комбо", 0.0, 1.0, 0.05, combo.smoke_amount,
			func(v: float): combo.smoke_amount = v; _apply_current())


## Перечитать конфиг в шейдер смонтированного эффекта.
func _apply_current() -> void:
	if _current_instance != null and _current_instance.has_method("apply_config"):
		_current_instance.apply_config()


func _set_status(text: String) -> void:
	_status_label.text = text


func _on_slider_changed(v: float, val: Label, step_v: float, on_changed: Callable) -> void:
	val.text = _format_value(v, step_v)
	on_changed.call(v)


func _format_value(v: float, step_v: float) -> String:
	if step_v >= 1.0:
		return "%d" % int(v)
	return "%.2f" % v
