extends Node
## Автолоад звука: процедурные SFX + лупы музыки.
##
## SFX генерируются кодом (синус в AudioStreamWAV), внешних файлов не надо.
## Музыка ищется в `assets/audio/music_v01.ogg` / `music_v02.ogg` (CC0);
## если файлов нет — тихо (плейсхолдер до поставки).

var _sfx: AudioStreamPlayer = null
var _music: AudioStreamPlayer = null


func _ready() -> void:
	_sfx = AudioStreamPlayer.new()
	_sfx.name = "Sfx"
	add_child(_sfx)
	_music = AudioStreamPlayer.new()
	_music.name = "Music"
	add_child(_music)
	_apply_volumes()


func _apply_volumes() -> void:
	if Configs.audio == null:
		return
	_sfx.volume_db = linear_to_db(Configs.audio.sfx_volume)
	_music.volume_db = linear_to_db(Configs.audio.music_volume)


## Сыграть процедурный тон.
func play_sfx(kind: StringName) -> void:
	if Configs.audio == null:
		return
	var freq: float = Configs.audio.click_freq
	if kind == &"success":
		freq = Configs.audio.success_freq
	elif kind == &"fail":
		freq = Configs.audio.fail_freq
	_sfx.stream = _tone(freq, Configs.audio.sfx_duration)
	_sfx.play()


## Запустить луп музыки версии (v01/v02). Нет файла — тихо.
func start_music(track: StringName) -> void:
	var path: String = "res://assets/audio/music_%s.ogg" % String(track)
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	if _music.stream == stream and _music.playing:
		return
	_music.stream = stream
	_music.play()


func stop_music() -> void:
	_music.stop()


## Сгенерировать синусоидальный WAV-тон.
func _tone(freq: float, duration: float) -> AudioStreamWAV:
	var rate: int = 22050
	var frames: int = int(rate * duration)
	var data := PackedByteArray()
	data.resize(frames)
	for i: int in frames:
		var t: float = float(i) / float(rate)
		var env: float = 1.0 - float(i) / float(frames)
		data[i] = int(127.5 + 120.0 * sin(TAU * freq * t) * env)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav
