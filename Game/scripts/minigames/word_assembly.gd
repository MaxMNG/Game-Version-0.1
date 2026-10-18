class_name WordAssembly
extends BaseMinigame
## Версия 0.1 «Сбор слов» по новому GDD (состояние VERSION_1).
##
## Облако кружится по часовой, символы вылетают по одному из центра.
## Порядок букв не важен: как только выбраны все нужные — автосборка.
## Любой клик по мусору — сразу провал раунда (поражений бесконечно).

const SYMBOL_SCENE: PackedScene = preload("res://scenes/ui/floaty_symbol.tscn")
const DIALOGUE_SCENE: PackedScene = preload("res://scenes/ui/dialogue_player.tscn")
const TRUST_SCENE: PackedScene = preload("res://scenes/ui/trust_indicator.tscn")

var _target: WordEntry = null
var _symbols: Array[FloatySymbol] = []
var _selected: Array[FloatySymbol] = []
var _angles: Dictionary = {}
var _successes: int = 0
var _used_words: Array[String] = []
var _lock: bool = false
var _spawning: bool = false
var _cloud_angle: float = 0.0
var _center: Vector2 = Vector2.ZERO

var _field: Control = null
var _links: Line2D = null
var _history_label: Label = null
var _progress_label: Label = null
var _title: LevelTitle = null
var _glow: Line2D = null
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

	_links = Line2D.new()
	_links.name = "Links"
	_links.antialiased = true
	_links.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_links.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(_links)
	_glow = Line2D.new()
	_glow.name = "LinksGlow"
	_glow.antialiased = true
	_glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_glow.end_cap_mode = Line2D.LINE_CAP_ROUND
	_glow.modulate = Color(1, 1, 1, 0.3)
	add_child(_glow)
	move_child(_glow, get_children().find(_links))

	_progress_label = Label.new()
	_progress_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_progress_label.offset_top = 84.0
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_progress_label.add_theme_font_size_override("font_size", Configs.version1.symbol_font_size)
	add_child(_progress_label)

	_title = LevelTitle.new()
	add_child(_title)

	_history_label = Label.new()
	_history_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_history_label.offset_left = 24.0
	_history_label.offset_top = -140.0
	_history_label.offset_right = 500.0
	_history_label.offset_bottom = -24.0
	_history_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_history_label.add_theme_font_size_override("font_size", Configs.version1.history_font_size)
	_history_label.modulate = Color(1, 1, 1, Configs.version1.history_opacity)
	add_child(_history_label)

	_dialogue = DIALOGUE_SCENE.instantiate() as DialoguePlayer
	_dialogue.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue.offset_top = -560.0
	_dialogue.offset_bottom = -340.0
	add_child(_dialogue)

	var trust: TrustIndicator = TRUST_SCENE.instantiate() as TrustIndicator
	trust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(trust)
	_update_labels()


func _process(delta: float) -> void:
	if _spawning or _symbols.is_empty():
		_update_links()
		return
	_center = get_viewport_rect().size / 2.0 + Vector2(0.0, Configs.version1.spawn_offset_y)
	_cloud_angle += Configs.version1.cloud_rotation_speed * delta
	_relayout_cloud()
	_update_links()


## Перечитать визуал из конфигов (для редактора уровней, живой тюнинг).
func apply_lab_config() -> void:
	var cfg: Version1Config = Configs.version1
	if _progress_label != null:
		_progress_label.add_theme_font_size_override("font_size", cfg.symbol_font_size)
	if _history_label != null:
		_history_label.add_theme_font_size_override("font_size", cfg.history_font_size)
		_history_label.modulate = Color(1, 1, 1, cfg.history_opacity)
	if _links != null:
		_links.width = cfg.link_width
	for s: FloatySymbol in _symbols:
		if is_instance_valid(s):
			s.add_theme_font_size_override("font_size", cfg.symbol_font_size)


func _relayout_cloud() -> void:
	var cfg: Version1Config = Configs.version1
	var count: int = _symbols.size()
	for i: int in count:
		var sym: FloatySymbol = _symbols[i]
		if not is_instance_valid(sym):
			continue
		var base_angle: float = float(_angles.get(sym.get_instance_id(), 0.0))
		var angle: float = base_angle + _cloud_angle
		var pos: Vector2 = _center + Vector2(cos(angle) * cfg.cloud_radius, sin(angle) * cfg.cloud_y_radius)
		if sym in _selected:
			pos = pos.move_toward(_center, cfg.magnet_pull)
		sym.set_base_pos(pos)


func _update_links() -> void:
	_links.clear_points()
	_glow.clear_points()
	if _selected.size() < 2:
		return
	_links.width = Configs.version1.link_width
	_links.default_color = Color(0.4, 1.0, 0.4, 1.0)
	_glow.width = Configs.version1.link_width * 3.0
	_glow.default_color = Color(0.4, 1.0, 0.4, 1.0)
	for sym: FloatySymbol in _selected:
		if is_instance_valid(sym):
			_links.add_point(sym.position + sym.size / 2.0)
			_glow.add_point(sym.position + sym.size / 2.0)


func _on_started() -> void:
	_successes = 0
	_used_words.clear()
	_history_label.text = ""
	Audio.start_music(&"v01")
	_title.launch("VERSION 0.1")
	_next_round()


func _next_round() -> void:
	_clear_field()
	_target = _pick_target()
	if _target == null:
		push_error("WordAssembly: пустая таблица words_v01")
		return
	_center = get_viewport_rect().size / 2.0 + Vector2(0.0, Configs.version1.spawn_offset_y)
	_spawn_cloud_async(_target.word)
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


func _spawn_cloud_async(word: String) -> void:
	_spawning = true
	_lock = true
	var cfg: Version1Config = Configs.version1
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
		_angles[sym.get_instance_id()] = angle
		var pos: Vector2 = _center + Vector2(cos(angle) * cfg.cloud_radius, sin(angle) * cfg.cloud_y_radius)
		sym.setup(glyphs[i], _center, cfg.drift_speed, cfg.drift_amplitude, cfg.symbol_font_size)
		sym.set_base_pos(pos)
		sym.symbol_clicked.connect(_on_symbol_clicked)
		_symbols.append(sym)
		await get_tree().create_timer(cfg.spawn_interval).timeout
	_cloud_angle = 0.0
	_relayout_cloud()
	_spawning = false
	_lock = false


func _clear_field() -> void:
	_selected.clear()
	_angles.clear()
	_links.clear_points()
	_glow.clear_points()
	for s: FloatySymbol in _symbols:
		if is_instance_valid(s):
			s.queue_free()
	_symbols.clear()


func _needed_count(glyph: String) -> int:
	var need: int = 0
	for i: int in _target.word.length():
		if _target.word.substr(i, 1) == glyph:
			need += 1
	var have: int = 0
	for s: FloatySymbol in _selected:
		if s.glyph == glyph:
			have += 1
	return need - have


func _on_symbol_clicked(symbol: FloatySymbol) -> void:
	if _lock or _spawning or _target == null:
		return
	if symbol in _selected:
		symbol.set_selected(false)
		_selected.erase(symbol)
		_update_links()
		return
	if _needed_count(symbol.glyph) <= 0:
		_on_round_fail(symbol)
		return
	symbol.set_selected(true)
	_selected.append(symbol)
	Audio.play_sfx(&"click")
	_update_links()
	if _selected.size() == _target.word.length():
		_on_word_success()


func _on_word_success() -> void:
	_lock = true
	_used_words.append(_target.word)
	_successes += 1
	Audio.play_sfx(&"success")
	Events.dialogue_line_requested.emit(StringName(_target.speaker), _target.reaction_text)
	for s: FloatySymbol in _selected:
		if is_instance_valid(s):
			s.flash_success()
	_update_labels()
	await get_tree().create_timer(Configs.version1.reaction_delay * 0.5).timeout
	for s: FloatySymbol in _symbols:
		if is_instance_valid(s) and not (s in _selected):
			s.fly_off(s.position - _center + Vector2(randf_range(-200.0, 200.0), randf_range(-200.0, 200.0)))
	var target: Vector2 = _history_label.get_global_rect().get_center()
	for s: FloatySymbol in _selected:
		if is_instance_valid(s):
			s.fly_off(target - s.position)
	_add_history(_target.word)
	_selected.clear()
	_angles.clear()
	_symbols.clear()
	_links.clear_points()
	_glow.clear_points()
	await get_tree().create_timer(Configs.version1.reaction_delay * 0.5).timeout
	_lock = false
	if _successes >= Configs.version1.words_to_win:
		succeed()
	else:
		_next_round()


func _on_round_fail(bad: FloatySymbol) -> void:
	_lock = true
	Audio.play_sfx(&"fail")
	_links.default_color = Color(1.0, 0.3, 0.3, 1.0)
	_glow.default_color = Color(1.0, 0.3, 0.3, 1.0)
	for s: FloatySymbol in _selected:
		if is_instance_valid(s):
			s.set_wrong()
	if is_instance_valid(bad):
		bad.set_wrong()
	_update_labels()
	var cfg: Version1Config = Configs.version1
	var line: String = cfg.gibberish_text
	if not cfg.comfort_lines.is_empty():
		line = cfg.comfort_lines[randi() % cfg.comfort_lines.size()]
	Events.dialogue_line_requested.emit(StringName(cfg.comfort_speaker), line)
	await get_tree().create_timer(0.4).timeout
	for s: FloatySymbol in _symbols:
		if is_instance_valid(s):
			s.fly_off(Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)))
	_selected.clear()
	_angles.clear()
	_symbols.clear()
	_links.clear_points()
	_glow.clear_points()
	await get_tree().create_timer(maxf(0.0, cfg.reaction_delay - 0.4)).timeout
	_lock = false
	_next_round()


func _add_history(word: String) -> void:
	if _history_label.text.is_empty():
		_history_label.text = word
	else:
		_history_label.text += "\n" + word


func _update_labels() -> void:
	if _progress_label != null:
		_progress_label.text = "%d / %d" % [_successes, Configs.version1.words_to_win]


func _on_succeeded() -> void:
	Game.upgrade_is_final = false
	Events.version_upgrade_requested.emit()
