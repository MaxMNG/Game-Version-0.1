class_name DialoguePlayer
extends VBoxContainer
## Очередь реплик: проигрывает массив DialogueLine по порядку.
##
## Используется интро, реакциями мини-игр и кат-сценами.
## Реакции через шину Events также складываются в очередь.

## Вся очередь проиграна.
signal queue_finished

var _queue: Array[DialogueLine] = []
var _current: int = -1
var _playing: bool = false
var _wait_timer: float = 0.0
var _waiting: bool = false

@onready var _bubble: DialogueBubble = %DialogueBubble


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.line_finished.connect(_on_bubble_line_finished)
	_bubble.hide_bubble()
	Events.dialogue_line_requested.connect(_on_line_requested)


func _process(delta: float) -> void:
	if not _waiting:
		return
	_wait_timer -= delta
	if _wait_timer <= 0.0:
		_waiting = false
		_play_next()


## Запустить очередь реплик (старая очередь отбрасывается).
func play(lines: Array[DialogueLine]) -> void:
	_queue = lines.duplicate()
	_current = -1
	_playing = true
	_waiting = false
	_play_next()


## Добавить реплику в конец текущей очереди.
func enqueue(line: DialogueLine) -> void:
	_queue.append(line)
	if not _playing:
		_playing = true
		_play_next()


## Пропуск: допечатать текущую или перейти к следующей.
func skip_current() -> void:
	if not _playing:
		return
	if _bubble.is_typing():
		_bubble.skip()
	else:
		_waiting = false
		_play_next()


## Остановить и спрятать.
func stop() -> void:
	_playing = false
	_waiting = false
	_queue.clear()
	_current = -1
	_bubble.hide_bubble()


## Играется ли сейчас очередь.
func is_playing() -> bool:
	return _playing


func _play_next() -> void:
	_current += 1
	if _current >= _queue.size():
		_playing = false
		_bubble.hide_bubble()
		queue_finished.emit()
		return
	var line: DialogueLine = _queue[_current]
	_align_bubble(line.speaker_id)
	_bubble.show_line(line.speaker_id, line.text)


## Зоны комментариев: мама слева, папа справа.
func _align_bubble(speaker_id: StringName) -> void:
	if String(speaker_id) == "dad":
		_bubble.size_flags_horizontal = Control.SIZE_SHRINK_END
	else:
		_bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN


func _on_bubble_line_finished() -> void:
	var pause: float = Configs.dialogue.default_pause_after
	if _current >= 0 and _current < _queue.size():
		pause = _queue[_current].pause_after
	_wait_timer = pause
	_waiting = true


func _on_line_requested(speaker_id: StringName, text: String) -> void:
	var line := DialogueLine.new()
	line.speaker_id = speaker_id
	line.text = text
	line.pause_after = Configs.dialogue.default_pause_after
	enqueue(line)
