class_name WordAssembly
extends BaseMinigame
## Версия 0.1 «Сбор слов» (состояние VERSION_1).
##
## Облако букв целевого слова + мусор; выбор строго по порядку,
## проверка кнопкой CONFIRM. 3 успеха — победа, проиграть нельзя.

const SYMBOL_SCENE: PackedScene = preload("res://scenes/ui/floaty_symbol.tscn")
const DIALOGUE_SCENE: PackedScene = preload("res://scenes/ui/dialogue_player.tscn")
const TRUST_SCENE: PackedScene = preload("res://scenes/ui/trust_indicator.tscn")

var _target: WordEntry = null
var _symbols: Array[FloatySymbol] = []
var _selected: Array[FloatySymbol] = []
var _successes: int = 0
var _used_words: Array[String] = []
var _lock: bool = false

var _field: Control = null
var _selected_label: Label = null
var _progress_label: Label = null
var _dialogue: DialoguePlayer = null


func _ready() -> void:
	minigame_id = &"word_assembly"
	_build_ui()
	start()


func _build_ui() -> void:
	_field = Control.new()
	_field.name = "Field"
	_field.set_anchors_preset(Control.PRESET_FULL_RECT)
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_field)

	var bottom := VBoxContainer.new()
	bottom.name = "Bottom"
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -320.0
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	# Пустые места панели клики не едят (кнопки внутри — едят, как положено).
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom)

	_selected_label = Label.new()
	_selected_label.name = "SelectedLabel"
	_selected_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_selected_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selected_label.add_theme_font_size_override("font_size", Configs.version1.symbol_font_size)
	bottom.add_child(_selected_label)

	var row := HBoxContainer.new()
	row.name = "Row"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(row)

	var confirm := Button.new()
	confirm.name = "ConfirmButton"
	confirm.text = "CONFIRM"
	confirm.add_theme_font_size_override("font_size", 28)
	confirm.pressed.connect(_on_confirm_pressed)
	row.add_child(confirm)

	var clear := Button.new()
	clear.name = "ClearButton"
	clear.text = "CLEAR"
	clear.add_theme_font_size_override("font_size", 28)
	clear.pressed.connect(_on_clear_pressed)
	row.add_child(clear)

	_progress_label = Label.new()
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(_progress_label)

	_dialogue = DIALOGUE_SCENE.instantiate() as DialoguePlayer
	_dialogue.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue.offset_top = -560.0
	_dialogue.offset_bottom = -340.0
	add_child(_dialogue)

	var trust: TrustIndicator = TRUST_SCENE.instantiate() as TrustIndicator
	trust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(trust)
	_update_labels()


func _on_started() -> void:
	_successes = 0
	_used_words.clear()
	_next_round()


func _next_round() -> void:
	_clear_field()
	_target = _pick_target()
	if _target == null:
		push_error("WordAssembly: пустая таблица words_v01")
		return
	_spawn_cloud(_target.word)
	_update_labels()


func _pick_target() -> WordEntry:
	var entries: Array[WordEntry] = Configs.words_v01.entries
	var fresh: Array[WordEntry] = []
	for e: WordEntry in entries:
		if not _used_words.has(e.word):
			fresh.append(e)
	if fresh.is_empty():
		_used_words.clear()
		fresh = entries.duplicate()
	return fresh[randi() % fresh.size()]


func _spawn_cloud(word: String) -> void:
	var cfg: Version1Config = Configs.version1
	# Центр спавна сдвинут вверх: эллипс целиком выше панели кнопок,
	# символы всегда доступны для наведения и клика.
	var center: Vector2 = get_viewport_rect().size / 2.0 + Vector2(0.0, cfg.spawn_offset_y)
	var glyphs: Array[String] = []
	for i: int in word.length():
		glyphs.append(word.substr(i, 1))
	var garbage_count: int = randi_range(cfg.garbage_min, cfg.garbage_max)
	for i: int in garbage_count:
		var pool: String = cfg.garbage_glyphs
		glyphs.append(pool.substr(randi() % pool.length(), 1))
	glyphs.shuffle()
	var count: int = glyphs.size()
	for i: int in count:
		var sym: FloatySymbol = SYMBOL_SCENE.instantiate() as FloatySymbol
		_field.add_child(sym)
		var angle: float = TAU * float(i) / float(count)
		var pos: Vector2 = center + Vector2(cos(angle) * cfg.cloud_radius, sin(angle) * cfg.cloud_y_radius)
		pos += Vector2(randf_range(-24.0, 24.0), randf_range(-24.0, 24.0))
		sym.setup(glyphs[i], pos, cfg.drift_speed, cfg.drift_amplitude, cfg.symbol_font_size)
		sym.symbol_clicked.connect(_on_symbol_clicked)
		_symbols.append(sym)


func _clear_field() -> void:
	_selected.clear()
	for s: FloatySymbol in _symbols:
		s.queue_free()
	_symbols.clear()


func _on_symbol_clicked(symbol: FloatySymbol) -> void:
	if _lock:
		return
	if symbol.selected:
		symbol.set_selected(false)
		_selected.erase(symbol)
	else:
		symbol.set_selected(true)
		_selected.append(symbol)
	_update_labels()


func _on_clear_pressed() -> void:
	for s: FloatySymbol in _selected:
		s.set_selected(false)
	_selected.clear()
	_update_labels()


func _on_confirm_pressed() -> void:
	if _lock or _target == null:
		return
	var built: String = ""
	for s: FloatySymbol in _selected:
		built += s.glyph
	if built == _target.word:
		_on_word_success()
	else:
		_on_gibberish()


func _on_word_success() -> void:
	_lock = true
	_used_words.append(_target.word)
	_successes += 1
	Trust.change(_target.trust_effect)
	Events.dialogue_line_requested.emit(StringName(_target.speaker), _target.reaction_text)
	_update_labels()
	await get_tree().create_timer(Configs.version1.reaction_delay).timeout
	_lock = false
	if _successes >= Configs.version1.words_to_win:
		succeed()
	else:
		_next_round()


func _on_gibberish() -> void:
	_lock = true
	for s: FloatySymbol in _selected:
		s.flash_error()
	Events.dialogue_line_requested.emit(
			StringName(Configs.version1.gibberish_speaker), Configs.version1.gibberish_text)
	await get_tree().create_timer(Configs.version1.reaction_delay).timeout
	_lock = false
	_next_round()


func _update_labels() -> void:
	var built: String = ""
	for s: FloatySymbol in _selected:
		built += s.glyph
	if _selected_label != null:
		_selected_label.text = built
	if _progress_label != null:
		_progress_label.text = "%d / %d" % [_successes, Configs.version1.words_to_win]


func _on_succeeded() -> void:
	Game.upgrade_is_final = false
	Events.version_upgrade_requested.emit()
