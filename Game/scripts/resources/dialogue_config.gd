class_name DialogueConfig
extends Resource
## Конфиг диалоговой системы (баблы, печать, очередь).
##
## Скорость печати и паузы — здесь, а не в коде бабла.

@export_group("Печать")
## Сколько символов печатается в секунду.
@export var chars_per_second: float = 30.0
## Пауза после завершения одной реплики, если у реплики нет своей (сек).
@export var default_pause_after: float = 0.6

@export_group("Вид")
## Максимальная ширина бабла в пикселях.
@export var bubble_max_width: float = 900.0
## Размер шрифта текста реплики.
@export var font_size: int = 28
## Размер шрифта имени спикера.
@export var speaker_font_size: int = 20
