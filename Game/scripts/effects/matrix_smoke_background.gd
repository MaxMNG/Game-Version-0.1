class_name MatrixSmokeBackground
extends Control
## Комбинированный фон «Матрица + Дым» (этап 4 работы над фоном).
##
## Стек из двух готовых слоёв: глифы матрицы снизу, вуаль дыма сверху
## (полупрозрачная — дым ещё менее заметен, чем в соло).
## Слои читают свои конфиги (matrix.tres / smoke.tres); здесь только
## доля видимости дыма из Configs.matrix_smoke.
## Контракт как у остальных фонов: приглушение и появление для интро.

## Приглушённый режим (пробрасывается в оба слоя).
var muted: bool = false

@onready var _matrix_layer: MatrixBackground = %MatrixHolder.get_child(0) as MatrixBackground
@onready var _smoke_layer: SmokeBackground = %SmokeHolder.get_child(0) as SmokeBackground

## Локальная копия материала дыма (чтобы доля видимости не утекала в соло-режим).
var _smoke_material: ShaderMaterial = null


func _ready() -> void:
	if _matrix_layer == null or _smoke_layer == null:
		push_error("MatrixSmokeBackground: нет слоёв MatrixLayer/SmokeLayer")
		return
	if Configs.matrix_smoke == null:
		push_error("MatrixSmokeBackground: Configs.matrix_smoke не загружен")
		return
	# Отвязываем материал дыма от общего ресурса сцены: прозрачность комбо
	# не должна влиять на вкладку «Дымка».
	var base_material: ShaderMaterial = _smoke_layer.material as ShaderMaterial
	if base_material != null:
		_smoke_material = base_material.duplicate() as ShaderMaterial
		_smoke_layer.material = _smoke_material
	apply_config()


## Перечитать параметры комбо (для живых настроек лаборатории).
func apply_config() -> void:
	if _matrix_layer == null or _smoke_layer == null:
		return
	_matrix_layer.apply_config()
	_smoke_layer.apply_config()
	if Configs.matrix_smoke == null or _smoke_material == null:
		return
	# Доля видимости дыма поверх глифов — только локальному материалу комбо.
	_smoke_material.set_shader_parameter(
			"amount", clampf(Configs.matrix_smoke.smoke_amount, 0.0, 1.0))


## Включить/выключить приглушённый режим обоих слоёв.
func set_muted(new_muted: bool) -> void:
	muted = new_muted
	if _matrix_layer != null:
		_matrix_layer.set_muted(new_muted)
	if _smoke_layer != null:
		_smoke_layer.set_muted(new_muted)


## Установить прогресс появления вручную (0 — фон полностью скрыт).
func set_reveal(progress: float) -> void:
	if _matrix_layer != null:
		_matrix_layer.set_reveal(progress)
	if _smoke_layer != null:
		_smoke_layer.set_reveal(progress)


## Появление фона из темноты за appear_duration слоёв.
## Для интро: вызывать после вспышки.
func play_appearance() -> void:
	if _matrix_layer != null:
		_matrix_layer.play_appearance()
	if _smoke_layer != null:
		_smoke_layer.play_appearance()
