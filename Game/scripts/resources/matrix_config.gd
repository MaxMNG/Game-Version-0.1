class_name MatrixConfig
extends Resource
## Конфиг фона «Матрица»: статичная сетка настоящих глифов из атласа,
## светятся только вокруг движущегося курсора.
##
## Все параметры визуала живут здесь (resources/configs/matrix.tres).
## Шейдер и скрипт получают значения только из этого конфига — хардкод запрещён.

@export_group("Сетка")
## Размер ячейки глифа в пикселях (лаборатория: слайдер 8–32 шаг 8).
@export var cell_size_px: float = 16.0

@export_group("Подсветка курсора")
## Радиус подсветки вокруг курсора (в UV-единицах).
@export var glow_radius: float = 0.18
## Мягкость спада яркости: больше — резче ядро, меньше — шире ореол.
@export var glow_softness: float = 2.0
## Насколько быстро движение мыши набирает заряд свечения.
@export var charge_gain: float = 12.0
## Максимальный заряд (нормирует яркость: свечение гаснет в покое).
@export var charge_max: float = 1.0
## Скорость экспоненциального затухания заряда и точек шлейфа (1/сек).
@export var charge_decay_rate: float = 1.6
## Общий усилитель яркости подсветки.
@export var charge_boost: float = 1.0
## Скорость сглаживания позиции курсора (1/сек).
@export var cursor_smooth_speed: float = 8.0

@export_group("Цвета")
## Цвет светящихся глифов (дефолт — голубой, меняется в лаборатории).
@export var color_glow: Color = Color(0.6, 0.95, 1.0, 1.0)
## Цвет широкого ореола вокруг курсора.
@export var color_halo: Color = Color(0.2, 0.5, 0.9, 1.0)
## Цвет тёмного фона между глифами.
@export var background_color: Color = Color(0.01, 0.02, 0.05, 1.0)
## Цвет статичного свечения в центре экрана (не зависит от курсора и глифов).
@export var color_center: Color = Color(0.15, 0.35, 0.7, 1.0)

@export_group("Центр")
## Сила статичного свечения в центре (0 — выключено).
@export var center_glow_strength: float = 0.15
## Радиус статичного свечения в центре (в UV-единицах).
@export var center_glow_radius: float = 0.35
## Минимальный заряд под курсором: свечение не гаснет ниже этой доли.
@export var charge_floor: float = 0.1

@export_group("Яркость")
## Общая яркость фона в обычном режиме.
@export var brightness: float = 0.9
## Яркость фона в приглушённом режиме (меню, диалоги).
@export var muted_brightness: float = 0.45
## Скорость плавного перехода яркости (1/сек).
@export var brightness_change_speed: float = 2.0

@export_group("Появление")
## Длительность появления фона из темноты (сек), для play_appearance().
@export var appear_duration: float = 1.2
