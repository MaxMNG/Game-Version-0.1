class_name SentenceAssembly
extends BaseMinigame
## Версия 0.2 «Сбор предложений» по новому GDD (состояние VERSION_2).
##
## Облако слов кружится (правильные 3–5 + квакозябры), вылет по одному.
## Порядок важен: клик — слово летит в центр; клик по зелёному —
## возврат его и всего хвоста. Проверка на каждую сборку: совпало —
## успех, мусор — провал, правильные но бессмысленно — провал порядка.

const DIALOGUE_SCENE: PackedScene = preload("res://scenes/ui/dialogue_player.tscn")
const TRUST_SCENE: PackedScene = preload("res://scenes/ui/trust_indicator.tscn")
const SCANLINE_SCENE: PackedScene = preload("res://scenes/effects/scanline_background.tscn")

var _set_id: String = ""
var _set_words: PackedStringArray = PackedStringArray()
var _chips: Array[Button] = []
var _angles: Dictionary = {}
var _is_garbage: Dictionary = {}
var _picked: Array[String] = []
var _picked_buttons: Array[Button] = []
var _successes: int = 0
var _bad_count: int = 0
var _bad_streak: int = 0
var _gibberish_count: int = 0
var _used_sets: Array[String] = []
var _lock: bool = false
var _spawning: bool = false
var _cloud_angle: float = 0.0
var _center: Vector2 = Vector2.ZERO

var _banner_label: Label = null
var _field: Control = null
var _title: LevelTitle = null
var _sentence_label: Label = null
var _counters_label: Label = null
var _dialogue: DialoguePlayer = null


func _ready() -> void:
	minigame_id = &"sentence_assembly"
	_build_ui()
	start()


func _build_ui() -> void:
	var scan: Control = SCANLINE_SCENE.instantiate() as Control
	scan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scan)
	move_child(scan, 0)
	_banner_label = Label.new()
	_banner_label.name = "BannerLabel"
	_banner_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_banner_label.offset_top = 120.0
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner_label.theme_type_variation = &"BodyLarge"
	_banner_label.text = Configs.version2.banner_text
	add_child(_banner_label)

	_title = LevelTitle.new()
	add_child(_title)

	_field = Control.new()
	_field.name = "Field"
	_field.set_anchors_preset(Control.PRESET_FULL_RECT)
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_field)

	_sentence_label = Label.new()
	_sentence_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_sentence_label.offset_top = -300.0
	_sentence_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sentence_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sentence_label.add_theme_font_size_override("font_size", Configs.version2.chip_font_size)
	add_child(_sentence_label)

	_counters_label = Label.new()
	_counters_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_counters_label.offset_top = -240.0
	_counters_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counters_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_counters_label)

	_dialogue = DIALOGUE_SCENE.instantiate() as DialoguePlayer
	_dialogue.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue.offset_top = -580.0
	_dialogue.offset_bottom = -380.0
	add_child(_dialogue)

	var trust: TrustIndicator = TRUST_SCENE.instantiate() as TrustIndicator
	trust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(trust)


func _process(delta: float) -> void:
	if _spawning or _chips.is_empty():
		return
	_center = get_viewport_rect().size / 2.0 + Vector2(0.0, Configs.version2.spawn_offset_y)
	_cloud_angle += Configs.version2.cloud_rotation_speed * delta
	_relayout_cloud()
	_layout_center()


## Перечитать визуал из конфигов (для редактора уровней, живой тюнинг).
func apply_lab_config() -> void:
	var cfg: Version2Config = Configs.version2
	for c: Button in _chips:
		if is_instance_valid(c):
			c.add_theme_font_size_override("font_size", cfg.chip_font_size)
	if _sentence_label != null:
		_sentence_label.add_theme_font_size_override("font_size", cfg.chip_font_size)


func _relayout_cloud() -> void:
	var cfg: Version2Config = Configs.version2
	for chip: Button in _chips:
		if not is_instance_valid(chip):
			continue
		if chip in _picked_buttons:
			continue
		var base_angle: float = float(_angles.get(chip.get_instance_id(), 0.0))
		var angle: float = base_angle + _cloud_angle
		chip.position = _center + Vector2(cos(angle) * cfg.cloud_radius, sin(angle) * cfg.cloud_y_radius) - chip.size / 2.0


func _layout_center() -> void:
	var spacing: float = Configs.version2.chip_font_size * 5.0
	for i: int in _picked_buttons.size():
		var chip: Button = _picked_buttons[i]
		if not is_instance_valid(chip):
			continue
		var slot: Vector2 = _center + Vector2((float(i) - float(_picked_buttons.size() - 1) / 2.0) * spacing, 0.0)
		chip.position = slot - chip.size / 2.0


func _on_started() -> void:
	_successes = 0
	_bad_count = 0
	_bad_streak = 0
	_gibberish_count = 0
	_used_sets.clear()
	_lock = true
	Audio.start_music(&"v02")
	_title.launch("VERSION 0.2")
	_update_counters()
	await get_tree().create_timer(Configs.version2.banner_duration).timeout
	_banner_label.visible = false
	_lock = false
	_next_set()


func _all_set_ids() -> Array[String]:
	var ids: Array[String] = []
	for e: SentenceEntry in Configs.sentences_v02.entries:
		if not ids.has(e.set_id):
			ids.append(e.set_id)
	return ids


func _next_set() -> void:
	var ids: Array[String] = _all_set_ids()
	if ids.is_empty():
		push_error("SentenceAssembly: пустая таблица sentences_v02")
		return
	var fresh: Array[String] = []
	for id: String in ids:
		if not _used_sets.has(id):
			fresh.append(id)
	if fresh.is_empty():
		_used_sets.clear()
		fresh = ids.duplicate()
	_set_id = fresh[randi() % fresh.size()]
	_used_sets.append(_set_id)
	var entries: Array[SentenceEntry] = Configs.sentences_v02.get_set(_set_id)
	if entries.is_empty():
		return
	_set_words = entries[0].words
	_spawn_chips_async()


func _spawn_chips_async() -> void:
	_spawning = true
	_lock = true
	_clear_chips()
	_center = get_viewport_rect().size / 2.0 + Vector2(0.0, Configs.version2.spawn_offset_y)
	var words: Array[String] = []
	for w: String in _set_words:
		words.append(w)
	var pool: Array[String] = Configs.version2.gibberish_words
	for i: int in Configs.version2.garbage_count:
		words.append(pool[randi() % pool.size()])
	words.shuffle()
	var count: int = words.size()
	for i: int in count:
		var chip := Button.new()
		chip.text = words[i]
		chip.theme_type_variation = &"TileButton"
		chip.add_theme_font_size_override("font_size", Configs.version2.chip_font_size)
		_field.add_child(chip)
		_angles[chip.get_instance_id()] = TAU * float(i) / float(count)
		_is_garbage[chip.get_instance_id()] = not (words[i] in _set_words)
		chip.position = _center - chip.size / 2.0
		chip.pressed.connect(_on_chip_pressed.bind(chip))
		_chips.append(chip)
		await get_tree().create_timer(Configs.version2.spawn_interval).timeout
	_cloud_angle = 0.0
	_relayout_cloud()
	_spawning = false
	_lock = false


func _clear_chips() -> void:
	_picked.clear()
	_picked_buttons.clear()
	_angles.clear()
	_is_garbage.clear()
	_update_sentence()
	for c: Button in _chips:
		if is_instance_valid(c):
			c.queue_free()
	_chips.clear()


func _on_chip_pressed(chip: Button) -> void:
	if _lock or _spawning:
		return
	if chip in _picked_buttons:
		_return_tail_from(chip)
		return
	if bool(_is_garbage.get(chip.get_instance_id(), false)):
		_on_gibberish()
		return
	_picked.append(chip.text)
	_picked_buttons.append(chip)
	chip.modulate = Configs.style.col_good
	Audio.play_sfx(&"click")
	_update_sentence()
	_layout_center()
	_check_picked()


func _return_tail_from(chip: Button) -> void:
	var idx: int = _picked_buttons.find(chip)
	if idx < 0:
		return
	for i: int in range(_picked_buttons.size() - 1, idx - 1, -1):
		var c: Button = _picked_buttons[i]
		if is_instance_valid(c):
			c.modulate = Configs.style.col_text
		_picked_buttons.remove_at(i)
		_picked.remove_at(i)
	_update_sentence()
	_relayout_cloud()


func _find_match() -> SentenceEntry:
	var built: String = " ".join(_picked)
	for e: SentenceEntry in Configs.sentences_v02.get_set(_set_id):
		if e.sentence.strip_edges().to_lower() == built.strip_edges().to_lower():
			return e
	return null


func _check_picked() -> void:
	var cfg: Version2Config = Configs.version2
	var found: SentenceEntry = _find_match()
	if found != null:
		_on_sentence_success(found)
		return
	if _picked.size() >= cfg.max_words:
		_on_order_bad()
		return
	if _picked.size() >= _set_words.size():
		_on_order_bad()


func _on_sentence_success(entry: SentenceEntry) -> void:
	_lock = true
	_successes += 1
	Audio.play_sfx(&"success")
	if entry.type == "bad":
		_bad_count += 1
		_bad_streak += 1
	else:
		_bad_streak = 0
	Trust.change(entry.trust_effect)
	Events.dialogue_line_requested.emit(StringName(entry.speaker), entry.reaction_text)
	_update_counters()
	await get_tree().create_timer(Configs.version2.reaction_delay).timeout
	_lock = false
	if _bad_streak >= Configs.version2.bad_limit:
		_fail_with(Game.State.VERSION_2, Configs.version2.bad_wipe_text)
		return
	if _successes >= Configs.version2.successes_to_win:
		if _bad_count == _successes:
			_fail_with(Game.State.VERSION_2, Configs.version2.bad_wipe_text)
			return
		succeed()
		return
	_next_set()


func _on_gibberish() -> void:
	_lock = true
	_gibberish_count += 1
	Audio.play_sfx(&"fail")
	Events.dialogue_line_requested.emit(
			StringName(Configs.version2.gibberish_speaker), Configs.version2.gibberish_text)
	_update_counters()
	await get_tree().create_timer(Configs.version2.reaction_delay).timeout
	_lock = false
	if _gibberish_count > Configs.version2.gibberish_limit:
		_fail_with(Game.State.VERSION_2, Configs.version2.wipe_text)
		return
	_spawn_chips_async()


func _on_order_bad() -> void:
	_lock = true
	_gibberish_count += 1
	Audio.play_sfx(&"fail")
	var cfg: Version2Config = Configs.version2
	var line: String = cfg.gibberish_text
	if not cfg.order_bad_lines.is_empty():
		line = cfg.order_bad_lines[randi() % cfg.order_bad_lines.size()]
	Events.dialogue_line_requested.emit(StringName(cfg.order_bad_speaker), line)
	_update_counters()
	await get_tree().create_timer(cfg.reaction_delay).timeout
	_lock = false
	if _gibberish_count > cfg.gibberish_limit:
		_fail_with(Game.State.VERSION_2, cfg.wipe_text)
		return
	_spawn_chips_async()


func _fail_with(_target_state: Game.State, message: String) -> void:
	Game.wipe_message = message
	Game.wipe_speaker = &"dad"
	fail()


func _update_sentence() -> void:
	if _sentence_label != null:
		_sentence_label.text = " ".join(_picked)


func _update_counters() -> void:
	if _counters_label != null:
		_counters_label.text = "%d / %d" % [_successes, Configs.version2.successes_to_win]


func _on_succeeded() -> void:
	Game.upgrade_is_final = true
	Events.version_upgrade_requested.emit()
