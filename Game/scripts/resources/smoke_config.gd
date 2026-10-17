class_name SmokeConfig
extends Resource
## Конфиг фона «Дымка-lite»: curl-подобный шум с гравитацией к центру.
##
## Все параметры визуала живут здесь (resources/configs/smoke.tres).
## Шейдер и скрипт получают значения только из этого конфига — хардкод запрещён.

@export_group("Шум")
## Масштаб шума: меньше значение — крупнее клубы.
@export var noise_scale: float = 3.0
## Число октав fbm-шума (детализация клубов).
@export var octave_count: int = 3
## Скорость эволюции клубов по времени.
@export var evolution_speed: float = 0.05
## Сила взаимного искажения слоёв (warp — «клубистость»).
@export var warp_amount: float = 0.7
## Расширение контраста шума: выше — резче границы клубов.
@export var noise_contrast: float = 2.2

@export_group("Центр")
## Точка, к которой гравитация стягивает дым (UV 0..1).
@export var gravity_center: Vector2 = Vector2(0.5, 0.5)
## Сила гравитации к центру (0 — дым свободно дрейфует).
@export var gravity_strength: float = 0.35
## Плотность первого (крупного) слоя.
@export var layer1_strength: float = 0.5
## Плотность второго (среднего) слоя.
@export var layer2_strength: float = 0.45
## Сила виньетки — затемнения краёв экрана (0 — без виньетки).
@export var vignette_strength: float = 0.5

@export_group("Курсор")
## Радиус влияния курсора (в UV-координатах).
@export var cursor_radius: float = 0.22
## Насколько быстро движение мыши набирает силу возмущения.
@export var cursor_gain: float = 12.0
## Максимальная сила возмущения от курсора.
@export var cursor_strength_max: float = 1.0
## Скорость экспоненциального затухания силы (1/сек).
@export var cursor_decay_rate: float = 1.6
## Завихрённость возмущения: доля перпендикулярного смещения.
@export var cursor_swirl: float = 0.55
## Скорость сглаживания позиции курсора (1/сек).
@export var cursor_smooth_speed: float = 8.0

@export_group("Цвета")
## Цвет глубокого фона (почти чёрный с лёгкой синевой).
@export var background_color: Color = Color(0.02, 0.025, 0.045, 1.0)
## Первый слой дыма (серо-голубой).
@export var layer1_color: Color = Color(0.35, 0.45, 0.6, 1.0)
## Второй слой дыма (светлый серо-голубой).
@export var layer2_color: Color = Color(0.55, 0.65, 0.8, 1.0)
## Общая сила цветовых слоёв (защита от «навязчивости», дефолт — еле заметно).
@export var accent_intensity: float = 0.35

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
