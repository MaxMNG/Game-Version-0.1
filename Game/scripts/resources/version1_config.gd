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

@export_group("Правила")
## Сколько слов нужно собрать для победы.
@export var words_to_win: int = 3

@export_group("Чушь")
## Кто говорит реплику на несобранное слово.
@export var gibberish_speaker: String = "dad"
## Реплика на чушь (EN).
@export var gibberish_text: String = "No, that's gibberish, let's try again"

@export_group("Темп")
## Пауза на реакцию (реплика + Trust) перед следующим набором (сек).
@export var reaction_delay: float = 1.2
