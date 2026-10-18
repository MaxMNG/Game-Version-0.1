class_name MenuConfig
extends Resource
## Конфиг главного меню (состояние MENU).
##
## Все задержки и тексты меню живут здесь, а не в коде.

@export_group("Тайминги")
## Задержка перед началом печати логотипа после запуска (сек).
@export var logo_delay: float = 1.0
## Задержка появления кнопки после окончания печати логотипа (сек).
@export var button_delay_after_logo: float = 1.0
## Интервал печати одного символа логотипа (сек).
@export var type_interval: float = 0.08

@export_group("GameIntro")
## Длительность мигающего квадрата вверху (сек).
@export var square_duration: float = 2.0
## Текст загрузки ОС (EN, многострочный).
@export var os_text: String = "ClosedAI BIOS v0.1\nMemory check... OK\nLoading weights... OK"
## Длительность показа текста ОС (сек).
@export var os_duration: float = 1.5
## Интервал печати медленной части логотипа «0.1» (сек).
@export var slow_interval: float = 0.5
## Пауза между символами «0», «.», «1» (сек).
@export var slow_pause: float = 1.0

@export_group("Тексты")
## Текст логотипа.
@export var logo_text: String = "VERSION 0.1"
## Текст кнопки старта.
@export var start_button_text: String = "START GAME"
## Незаметная подпись версии.
@export var alpha_text: String = "alpha"
## Текст экрана-заглушки финала прототипа.
@export var prototype_complete_text: String = "PROTOTYPE COMPLETE"
