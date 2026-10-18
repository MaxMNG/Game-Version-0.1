class_name DialogueBubble
extends PanelContainer
## Текстовый бабл с эффектом «печатающегося» текста.
##
## Показывает одну реплику: имя спикера + постепенно печатающийся текст.
## Пропуск — через skip(): допечатывает мгновенно, повторный вызов — сигнал.

## Печать текущей реплики завершена.
signal line_finished

var _full_text: String = ""
var _shown_chars: float = 0.0
var _typing: bool = false
var _cps: float = 30.0

@onready var _speaker_label: Label = %SpeakerLabel
@onready var _text_label: Label = %TextLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_config()
	hide_bubble()


## Перечитать скорость печати и шрифты из конфига.
func _apply_config() -> void:
	if Configs.dialogue == null:
		return
	_cps = Configs.dialogue.chars_per_second
	_text_label.add_theme_font_size_override("font_size", Configs.dialogue.font_size)
	_speaker_label.add_theme_font_size_override("font_size", Configs.dialogue.speaker_font_size)
	custom_minimum_size.x = Configs.dialogue.bubble_max_width


func _process(delta: float) -> void:
	if not _typing:
		return
	_shown_chars += _cps * delta
	var count: int = int(_shown_chars)
	if count >= _full_text.length():
		_text_label.text = _full_text
		_typing = false
		line_finished.emit()
	else:
		_text_label.text = _full_text.left(count)


## Показать реплику с печатью.
func show_line(speaker_id: StringName, text: String) -> void:
	_full_text = text
	_shown_chars = 0.0
	_typing = true
	_speaker_label.text = String(speaker_id).to_upper()
	_text_label.text = ""
	visible = true


## Пропуск: если печатается — допечатать, иначе сообщить что готово к следующей.
## Возвращает true, если печать была завершена этим вызовом или уже завершена.
func skip() -> bool:
	if _typing:
		_text_label.text = _full_text
		_shown_chars = float(_full_text.length())
		_typing = false
		line_finished.emit()
		return false
	return true


## Скрыть бабл.
func hide_bubble() -> void:
	visible = false
	_typing = false


## Печатается ли сейчас текст.
func is_typing() -> bool:
	return _typing
