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
]

## Запасной вариант, смонтирован пока эффекты не готовы.
const FALLBACK_TITLE: String = "Небула (запас)"
const FALLBACK_SCENE: String = "res://scenes/effects/background_effect.tscn"

var _current_id: String = ""
var _current_instance: Control = null
var _current_config: Resource = null

@onready var _slot: Control = %BackgroundSlot
@onready var _rows: VBoxContainer = %SettingsRows
@onready var _save_button: Button = %SaveButton
@onready var _save_status: Label = %SaveStatus
@onready var _status_label: Label = %StatusLabel
@onready var _btn_ring: Button = %BtnRing
@onready var _btn_matrix: Button = %BtnMatrix
@onready var _btn_smoke: Button = %BtnSmoke


func _ready() -> void:
	_btn_ring.pressed.connect(_on_effect_button.bind("ring"))
	_btn_matrix.pressed.connect(_on_effect_button.bind("matrix"))
	_btn_smoke.pressed.connect(_on_effect_button.bind("smoke"))
	_save_button.pressed.connect(_on_save_pressed)
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
	row.add_theme_constant_override("separation", 8)
	row.custom_minimum_size = Vector2(0, 32)
	var lab := Label.new()
	lab.text = label_text
	lab.add_theme_font_size_override("font_size", 16)
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
	val.add_theme_font_size_override("font_size", 16)
	val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	val.text = _format_value(initial, step_v)
	slider.value_changed.connect(_on_slider_changed.bind(val, step_v, on_changed))
	row.add_child(lab)
	row.add_child(slider)
	row.add_child(val)
	_rows.add_child(row)


## Добавить в панель строку-выбор цвета (для живых настроек эффекта).
func add_color(label_text: String, initial: Color, on_changed: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.custom_minimum_size = Vector2(0, 32)
	var lab := Label.new()
	lab.text = label_text
	lab.add_theme_font_size_override("font_size", 16)
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.custom_minimum_size = Vector2(118, 0)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var picker := ColorPickerButton.new()
	picker.color = initial
	picker.custom_minimum_size = Vector2(64, 0)
	picker.color_changed.connect(func(c: Color): on_changed.call(c))
	row.add_child(lab)
	row.add_child(picker)
	_rows.add_child(row)


## Очистить панель настроек.
func clear_panel() -> void:
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
	_rows.add_child(lab)
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
	return null


func _build_panel() -> void:
	clear_panel()
	match _current_id:
		"ring":
			_build_ring_panel()
		_:
			var lab := Label.new()
			lab.text = "Нет настроек."
			_rows.add_child(lab)


func _build_ring_panel() -> void:
	var ring: RingConfig = Configs.ring
	if ring == null:
		return
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
	add_color("Цвет A", ring.color_a,
			func(c: Color): ring.color_a = c; _apply_current())
	add_color("Цвет B", ring.color_b,
			func(c: Color): ring.color_b = c; _apply_current())
	add_color("Цвет C", ring.color_c,
			func(c: Color): ring.color_c = c; _apply_current())


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
