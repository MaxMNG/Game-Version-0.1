class_name Version2Config
extends Resource
## Конфиг версии 0.2 «Сбор предложений».
##
## Длина предложений, лимиты победы/поражения и особые реплики.

@export_group("Правила")
## Минимальная длина предложения в словах.
@export var min_words: int = 3
## Максимальная длина предложения в словах.
@export var max_words: int = 5
## Сколько предложений нужно для победы.
@export var successes_to_win: int = 3
## Сколько чуши ведёт к стиранию (строго больше этого числа).
@export var gibberish_limit: int = 5
## Сколько плохих успехов подряд ведёт к особому стиранию.
@export var bad_limit: int = 3

@export_group("Облако")
## Скорость вращения облака слов по часовой (рад/сек).
@export var cloud_rotation_speed: float = 0.2
## Горизонтальный радиус облака слов (пикселей).
@export var cloud_radius: float = 300.0
## Вертикальный радиус облака слов (пикселей).
@export var cloud_y_radius: float = 220.0
## Сдвиг центра облака вверх от центра экрана (пикселей).
@export var spawn_offset_y: float = -80.0
## Интервал вылета слов по одному из центра (сек).
@export var spawn_interval: float = 0.15
## Квакозябры-мусор для облака (смесь латиницы, CJK, цифр).
@export var gibberish_words: Array[String] = ["@1<", "静34月", ">(21o", "##%", "žλ9", "§§§", "99x", "؟؟؟"]
## Сколько мусорных слов в облаке (остальные — правильные 3–5).
@export var garbage_count: int = 4

@export_group("Порядок")
## Реплики на бессмысленный порядок правильных слов (EN, рандом 1 из 3).
@export var order_bad_lines: Array[String] = ["Not bad, but the order is off.", "Words are right, order is wrong.", "Close — shuffle them around."]
## Кто говорит про плохой порядок.
@export var order_bad_speaker: String = "dad"

@export_group("Тексты")
## Баннер при входе в версию.
@export var banner_text: String = "You have been upgraded to version 0.2"
## Длительность показа баннера (сек).
@export var banner_duration: float = 2.0
## Реплика на чушь (EN).
@export var gibberish_text: String = "No, that's gibberish. Again."
## Кто говорит реплику на чушь.
@export var gibberish_speaker: String = "dad"
## Реплика стирания после лимита чуши (EN).
@export var wipe_text: String = "It's not coping. Wipe it, we'll try again."
## Реплика особого стирания после плохих предложений (EN).
@export var bad_wipe_text: String = "It passed, but I don't like the phrases it's making... Let's start over."
## Размер шрифта чипов слов.
@export var chip_font_size: int = 32

@export_group("Темп")
## Пауза на реакцию (реплика + Trust) перед следующим набором (сек).
@export var reaction_delay: float = 1.2
