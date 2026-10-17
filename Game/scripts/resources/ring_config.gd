class_name RingConfig
extends Resource
## Конфиг фона «Кольцо-эквалайзер»: геометрия кольца, дрожание, магнит курсора.
##
## Все параметры визуала живут здесь (resources/configs/ring.tres).
## Шейдер и скрипт получают значения только из этого конфига — хардкод запрещён.

@export_group("Кольцо")
## Число радиальных баров.
@export var bar_count: int = 150
## Радиус базового круга (в аспект-корректных единицах, углы экрана ~1.0).
@export var ring_radius: float = 0.34
## Базовая длина бара (при нулевом дрожании и без курсора).
@export var bar_base_length: float = 0.02
## Максимальная добавка к длине от дрожания.
@export var bar_span: float = 0.10
## Доля сектора, занятая баром (0..1, остальное — зазор).
@export var bar_width: float = 0.7
## Общая длина баров, проценты (100 — полная, 0 — баров практически нет).
@export var bar_length: float = 100.0
## Сила свечения вокруг кольца.
@export var glow_strength: float = 0.6
## Скорость медленного вращения узора (оборотов нет — доли радиана/сек).
@export var rotation_speed: float = 0.02

@export_group("Дрожание")
## Амплитуда хаотичного шевеления баров (0 — все бары одинаковые).
@export var jitter_amount: float = 0.8
## Скорость дрожания.
@export var jitter_speed: float = 0.6

@export_group("Магнит курсора")
## Радиус притяжения (в тех же единицах, что ring_radius).
@export var magnet_radius: float = 0.22
## Насколько быстро движение мыши набирает силу магнита.
@export var magnet_gain: float = 12.0
## Максимальная сила магнита.
@export var magnet_strength_max: float = 1.0
## Скорость экспоненциального затухания силы (1/сек).
@export var magnet_decay_rate: float = 1.6
## Насколько сильно магнит вытягивает бары (добавка к длине).
@export var magnet_lift: float = 0.08
## Скорость сглаживания позиции курсора (1/сек).
@export var cursor_smooth_speed: float = 8.0

@export_group("Цвета")
## Первый цвет градиента по кругу (циан).
@export var color_a: Color = Color(0.2, 0.95, 1.0, 1.0)
## Второй цвет градиента (зелень).
@export var color_b: Color = Color(0.3, 1.0, 0.55, 1.0)
## Третий цвет градиента (маджента).
@export var color_c: Color = Color(1.0, 0.25, 0.9, 1.0)
## Резкость переходов градиента: меньше — переходы мягче/размытее.
@export var gradient_sharp: float = 1.5

@export_group("Внутренняя граница")
## Амплитуда случайных движений внутренней границы (доля от bar_span).
@export var inner_jitter_amount: float = 0.6
## Скорость движений внутренней границы.
@export var inner_jitter_speed: float = 0.4

@export_group("Прозрачность")
## Общая прозрачность всех баров (0 — бары невидимы).
@export var bar_opacity: float = 1.0
## Минимальная видимость бара (1 — все бары одинаково яркие).
@export var alpha_min: float = 0.35
## Скорость переливания прозрачности.
@export var alpha_speed: float = 0.5
## Насколько магнит делает ближние бары заметнее (0.5 = +50%).
@export var magnet_visibility_boost: float = 0.5

@export_group("Яркость")
## Общая яркость фона в обычном режиме.
@export var brightness: float = 1.0
## Яркость фона в приглушённом режиме (меню, диалоги).
@export var muted_brightness: float = 0.55
## Скорость плавного перехода яркости (1/сек).
@export var brightness_change_speed: float = 2.0

@export_group("Появление")
## Длительность появления фона из темноты (сек), для play_appearance().
@export var appear_duration: float = 1.2
