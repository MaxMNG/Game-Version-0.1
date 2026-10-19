class_name FxConfig
extends Resource
## Конфиг эффекта Arcada Effector (прогон Этапа 1.6, F5).
##
## Эффект — данные: атлас из Effector (через Tools/import_afx_atlas.py),
## нарезка SpriteFrames, размер, длительность, «громкость» 0–2.
## Ноль хардкода — как в `godot-effect`.

## Название для реестра.
@export var display_name: String = ""
## Нарезка атласа (генерируется импортёром; null — эффект молчит).
@export var frames: SpriteFrames
## Кадров в секунду (перекрывает скорость анимации).
@export var fps: float = 12.0
## Целевой размер спрайта на экране (px).
@export var target_size: Vector2 = Vector2(512, 512)
## «Громкость» эффекта 0–2 (0 — едва заметно, 2 — полноэкранный акцент).
@export_range(0, 2, 1) var volume: int = 1
## Исходник Effector (для правки): путь вида `res://assets/effects/src/<name>.json`.
@export var src_json: String = ""
