class_name AudioConfig
extends Resource
## Конфиг звука (громкости, частоты процедурных SFX).
##
## Музыка — лупы из `assets/audio/` (CC0-плейсхолдер до поставки файлов).

@export_group("Громкость")
## Громкость SFX (0–1).
@export var sfx_volume: float = 0.7
## Громкость музыки (0–1).
@export var music_volume: float = 0.5

@export_group("Процедурные SFX")
## Частота клика (Гц).
@export var click_freq: float = 880.0
## Частота успеха (Гц).
@export var success_freq: float = 660.0
## Частота провала (Гц).
@export var fail_freq: float = 220.0
## Длительность SFX (сек).
@export var sfx_duration: float = 0.12
