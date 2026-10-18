class_name SentenceAssembly
extends BaseMinigame
## Версия 0.2 «Сбор предложений» (состояние VERSION_2).
##
## Набор слов → чипы + мусор, клики собирают строку 3–5 слов, CONFIRM проверяет
## по таблице набора. Победа — 3 успеха; >5 чуши — стирание;
## 3 плохих подряд — особое стирание. Доверие при стирании сохраняется.

const DIALOGUE_SCENE: PackedScene = preload("res://scenes/ui/dialogue_player.tscn")
const TRUST_SCENE: PackedScene = preload("res://scenes/ui/trust_indicator.tscn")

var _set_id: String = ""
var _set_words: PackedStringArray = PackedStringArray()
var _chips: Array[Button] = []
var _picked: Array[String] = []
var _picked_buttons: Array[Button] = []
var _successes: int = 0
var _bad_count: int = 0
var _bad_streak: int = 0
var _gibberish_count: int = 0
var _used_sets: Array[String] = []
var _lock: bool = false

var _banner_label: Label = null
var _chips_box: HFlowContainer = null
var _sentence_label: Label = null
var _counters_label: Label = null
var _dialogue: DialoguePlayer = null


func _ready() -> void:
	minigame_id = &"sentence_assembly"
	_build_ui()
	start()


func _build_ui() -> void:
	_banner_label = Label.new()
	_banner_label.name = "BannerLabel"
	_banner_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_banner_label.offset_top = 120.0
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner_label.add_theme_font_size_override("font_size", 36)
	_banner_label.text = Configs.version2.banner_text
	add_child(_banner_label)

	var flow := HFlowContainer.new()
	flow.name = "ChipsBox"
	flow.set_anchors_preset(Control.PRESET_FULL_RECT)
	flow.offset_left = 360.0
	flow.offset_right = -360.0
	flow.offset_top = 200.0
	flow.offset_bottom = -320.0
	flow.alignment = FlowContainer.ALIGNMENT_CENTER
	flow.add_theme_constant_override("h_separation", 12)
	flow.add_theme_constant_override("v_separation", 12)
	# Пустые места раскладки клики не едят (чипы-кнопки внутри — едят).
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flow)
	_chips_box = flow

	var bottom := VBoxContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -300.0
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom)

	_sentence_label = Label.new()
	_sentence_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sentence_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sentence_label.add_theme_font_size_override("font_size", Configs.version2.chip_font_size)
	_sentence_label.text = ""
	bottom.add_child(_sentence_label)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(row)

	var confirm := Button.new()
	confirm.text = "CONFIRM"
	confirm.add_theme_font_size_override("font_size", 28)
	confirm.pressed.connect(_on_confirm_pressed)
	row.add_child(confirm)

	var clear := Button.new()
	clear.text = "CLEAR"
	clear.add_theme_font_size_override("font_size", 28)
	clear.pressed.connect(_on_clear_pressed)
	row.add_child(clear)

	_counters_label = Label.new()
	_counters_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counters_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(_counters_label)

	_dialogue = DIALOGUE_SCENE.instantiate() as DialoguePlayer
	_dialogue.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue.offset_top = -580.0
	_dialogue.offset_bottom = -380.0
	add_child(_dialogue)

	var trust: TrustIndicator = TRUST_SCENE.instantiate() as TrustIndicator
	trust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(trust)


func _on_started() -> void:
	_successes = 0
	_bad_count = 0
	_bad_streak = 0
	_gibberish_count = 0
	_used_sets.clear()
	_lock = true
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
	_spawn_chips()


func _spawn_chips() -> void:
	for c: Button in _chips:
		c.queue_free()
	_chips.clear()
	_picked.clear()
	_picked_buttons.clear()
	_update_sentence()
	var words: Array[String] = []
	for w: String in _set_words:
		words.append(w)
	var pool: String = Configs.version1.garbage_glyphs
	for i: int in 3:
		words.append(pool.substr(randi() % pool.length(), 1) + pool.substr(randi() % pool.length(), 1))
	words.shuffle()
	for w: String in words:
		var chip := Button.new()
		chip.text = w
		chip.add_theme_font_size_override("font_size", Configs.version2.chip_font_size)
		chip.pressed.connect(_on_chip_pressed.bind(chip))
		_chips_box.add_child(chip)
		_chips.append(chip)


func _on_chip_pressed(chip: Button) -> void:
	if _lock:
		return
	if _picked_buttons.has(chip):
		_picked_buttons.erase(chip)
		_picked.erase(chip.text)
		chip.modulate = Color(1, 1, 1, 1)
	else:
		if _picked.size() >= Configs.version2.max_words:
			return
		_picked.append(chip.text)
		_picked_buttons.append(chip)
		chip.modulate = Color(0.4, 1.0, 0.4, 1.0)
	_update_sentence()


func _on_clear_pressed() -> void:
	for c: Button in _picked_buttons:
		c.modulate = Color(1, 1, 1, 1)
	_picked.clear()
	_picked_buttons.clear()
	_update_sentence()


func _on_confirm_pressed() -> void:
	if _lock:
		return
	var cfg: Version2Config = Configs.version2
	if _picked.size() < cfg.min_words or _picked.size() > cfg.max_words:
		_on_gibberish()
		return
	var built: String = " ".join(_picked)
	var found: SentenceEntry = null
	for e: SentenceEntry in Configs.sentences_v02.get_set(_set_id):
		if e.sentence.strip_edges().to_lower() == built.strip_edges().to_lower():
			found = e
			break
	if found == null:
		_on_gibberish()
	else:
		_on_sentence_success(found)


func _on_sentence_success(entry: SentenceEntry) -> void:
	_lock = true
	_successes += 1
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
	Events.dialogue_line_requested.emit(
			StringName(Configs.version2.gibberish_speaker), Configs.version2.gibberish_text)
	_update_counters()
	await get_tree().create_timer(Configs.version2.reaction_delay).timeout
	_lock = false
	if _gibberish_count > Configs.version2.gibberish_limit:
		_fail_with(Game.State.VERSION_2, Configs.version2.wipe_text)
		return
	_spawn_chips()


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
