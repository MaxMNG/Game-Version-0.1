class_name Version1Config
extends Resource
## Конфиг версии 0.1 «Сбор слов».
##
## Количество мусора, дрейф, условие победы и реплика на чушь.

@export_group("Облако")
## Минимальное число мусорных глифов в облаке.
@export var garbage_min: int = 7
## Максимальное число мусорных глифов в облаке.
@export var garbage_max: int = 12
## Скорость дрейфа символов (пикселей в секунду, масштаб синусоиды).
@export var drift_speed: float = 30.0
## Амплитуда дрейфа в пикселях.
@export var drift_amplitude: float = 18.0
## Горизонтальный радиус облака-сетки от центра спавна (пикселей).
@export var cloud_radius: float = 260.0
## Вертикальный радиус облака-сетки (пикселей, меньше горизонтального —
## нижние символы не должны уходить под панель кнопок).
@export var cloud_y_radius: float = 200.0
## Сдвиг центра спавна вверх от центра экрана (пикселей, отрицательный — вверх).
@export var spawn_offset_y: float = -120.0
## Набор мусорных глифов «битой кодировки».
@export var garbage_glyphs: String = "#$%&@?*§±×÷<>~^"
## Размер шрифта символов облака.
@export var symbol_font_size: int = 48
## Интервал появления символов по одному из центра (сек).
@export var spawn_interval: float = 0.12
## Скорость вращения облака по часовой (рад/сек).
@export var cloud_rotation_speed: float = 0.25
## Сила притяжения выбранных символов к центру облака (пикселей).
@export var magnet_pull: float = 60.0
## Толщина зелёных линий связи.
@export var link_width: float = 3.0

@export_group("Правила")
## Сколько слов нужно собрать для победы.
@export var words_to_win: int = 3
## Размер шрифта поля истории (левый нижний угол).
@export var history_font_size: int = 28
## Прозрачность слов в истории (0–1).
@export var history_opacity: float = 0.5

@export_group("Утешения")
## Кто говорит утешение при ошибке.
@export var comfort_speaker: String = "mom"
## 10 утешительных реплик на ошибку (EN, рандом).
@export var comfort_lines: Array[String] = ["It's okay, try again.", "Nothing scary, once more.", "Hmm, almost. Again.", "Don't worry, little one.", "Again, you can do it.", "So close. Once more.", "Shake it off, retry.", "Learning takes time.", "No rush, try again.", "Oops. Let's try again."]

@export_group("Чушь")
## Кто говорит реплику на несобранное слово.
@export var gibberish_speaker: String = "dad"
## Реплика на чушь (EN).
@export var gibberish_text: String = "No, that's gibberish, let's try again"

@export_group("Темп")
## Пауза на реакцию (реплика + Trust) перед следующим набором (сек).
@export var reaction_delay: float = 1.2
