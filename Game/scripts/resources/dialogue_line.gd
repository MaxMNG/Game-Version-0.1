class_name DialogueLine
extends Resource
## Одна реплика диалога (спикер + текст + пауза после).
##
## Используется очередью DialoguePlayer для интро, реакций и кат-сцен.

## Идентификатор говорящего: "mom" / "dad".
@export var speaker_id: StringName = &"mom"
## Текст реплики (EN, язык игры — английский).
@export var text: String = ""
## Пауза после реплики в секундах.
@export var pause_after: float = 0.5
