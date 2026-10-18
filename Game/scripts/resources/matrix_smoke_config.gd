class_name MatrixSmokeConfig
extends Resource
## Конфиг комбинированного фона «Матрица + Дым».
##
## Слои переиспользуют свои конфиги (matrix.tres / smoke.tres) без изменений;
## здесь только степень присутствия дыма в комбо.
## Живёт в resources/configs/matrix_smoke.tres.

@export_group("Комбо")
## Доля видимости слоя дыма поверх глифов (0 — дыма нет, 1 — как в соло).
@export var smoke_amount: float = 0.35

@export_group("Слои")
## Показывать слой матрицы (глифы).
@export var show_matrix: bool = true
## Показывать слой дыма (вуаль).
@export var show_smoke: bool = true
