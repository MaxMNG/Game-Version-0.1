class_name NebulaConfig
extends Resource
## Конфиг небула-фона: палитра, шум, реакция на курсор.
##
## Все параметры визуала «живого» фона живут здесь (resources/configs/nebula.tres).
## Шейдер и скрипт получают значения только из этого конфига — хардкод запрещён.

@export_group("Палитра")
## Цвет глубокого фона (почти чёрный, с лёгкой синевой).
@export var background_color: Color = Color(0.02, 0.01, 0.05, 1.0)
## Основной фиолетовый цвет облаков.
@export var purple_color: Color = Color(0.3, 0.08, 0.55, 1.0)
## Яркий пурпурный (маджента) цвет облаков.
@export var magenta_color: Color = Color(0.6, 0.15, 0.8, 1.0)
## Зелёный акцентный цвет (чернильное облако в углу).
@export var green_color: Color = Color(0.1, 0.75, 0.4, 1.0)
## Общая сила цветовых слоёв поверх фона (защита от «навязчивости»).
@export var accent_intensity: float = 0.7

@export_group("Шум")
## Масштаб шума: меньше значение — крупнее облака.
@export var noise_scale: float = 3.0
## Число октав fbm-шума (детализация облаков).
@export var octave_count: int = 4
## Скорость эволюции облаков по времени.
@export var evolution_speed: float = 0.05
## Сила взаимного искажения (warp) слоёв шума — «чернильность».
@export var warp_amount: float = 0.7
## Расширение контраста шума: выше — резче границы облаков и ярче пятна.
@export var noise_contrast: float = 2.8
## Позиция зелёного облака в UV (0..1, 0..1).
@export var green_anchor: Vector2 = Vector2(0.66, 0.3)
## Радиус зелёного облака в UV-координатах.
@export var green_radius: float = 0.26

@export_group("Слои")
## Плотность крупного фиолетового слоя (0 — слоя нет).
@export var layer1_strength: float = 0.7
## Плотность среднего пурпурного слоя (0 — слоя нет).
@export var layer2_strength: float = 0.7
## Сила виньетки — затемнения краёв экрана (0 — без виньетки).
@export var vignette_strength: float = 0.35

@export_group("Курсор")
## Радиус влияния курсора (в UV-координатах).
@export var cursor_radius: float = 0.22
## Насколько быстро движение мыши набирает силу возмущения.
@export var cursor_gain: float = 12.0
## Максимальная сила возмущения от курсора.
@export var cursor_strength_max: float = 1.0
## Скорость экспоненциального затухания силы возмущения (1/сек).
@export var cursor_decay_rate: float = 1.6
## Завихрённость возмущения: доля перпендикулярного («размазывающего») смещения.
@export var cursor_swirl: float = 0.55
## Скорость сглаживания позиции курсора (1/сек).
@export var cursor_smooth_speed: float = 8.0

@export_group("Яркость")
## Общая яркость фона в обычном режиме.
@export var brightness: float = 1.0
## Яркость фона в приглушённом режиме (меню, диалоги).
@export var muted_brightness: float = 0.55
## Скорость плавного перехода яркости (1/сек).
@export var brightness_change_speed: float = 2.0

@export_group("Проявление")
## Центр маски проявления в UV (0..1, 0..1) — эффект живёт вокруг него.
@export var reveal_center: Vector2 = Vector2(0.5, 0.5)
## Радиус видимой зоны от центра (в аспект-корректных единицах).
## Углы экрана (дистанция ~1.02) уходят в темноту.
@export var reveal_radius: float = 0.6
## Мягкость перехода маски в темноту за радиусом.
@export var reveal_softness: float = 0.5
## Длительность появления фона из центра (сек), для play_appearance().
@export var reveal_appear_duration: float = 1.2
