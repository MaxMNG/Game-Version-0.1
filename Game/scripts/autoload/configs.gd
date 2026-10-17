extends Node
## Точка доступа ко всем конфигурационным ресурсам игры.
##
## Все числовые значения баланса живут в .tres-ресурсах (resources/configs/),
## а не в коде. Скрипты читают их только через этот автолоад.

## Главный конфиг баланса. Загружается один раз при старте игры.
var balance: BalanceConfig

## Конфиг небула-фона (палитра, шум, реакция на курсор).
var nebula: NebulaConfig

## Конфиг фона «Кольцо-эквалайзер» (геометрия, дрожание, магнит курсора).
var ring: RingConfig

## Конфиг фона «Матрица» (сетка глифов, потоки, шлейф курсора).
var matrix: MatrixConfig

## Конфиг фона «Дымка-lite» (шум, гравитация к центру, курсор).
var smoke: SmokeConfig

## Конфиг комбо «Матрица + Дым» (доля видимости дыма поверх глифов).
var matrix_smoke: MatrixSmokeConfig

## Таблица слов версии 0.1 (мини-игра «Сбор слов»).
var words_v01: WordsTable

## Таблица предложений версии 0.2 (мини-игра «Сбор предложений»).
var sentences_v02: SentencesTable


func _ready() -> void:
	balance = load("res://resources/configs/balance.tres") as BalanceConfig
	if balance == null:
		push_error("Configs: не удалось загрузить resources/configs/balance.tres")

	nebula = load("res://resources/configs/nebula.tres") as NebulaConfig
	if nebula == null:
		push_error("Configs: не удалось загрузить resources/configs/nebula.tres")

	ring = load("res://resources/configs/ring.tres") as RingConfig
	if ring == null:
		push_error("Configs: не удалось загрузить resources/configs/ring.tres")

	matrix = load("res://resources/configs/matrix.tres") as MatrixConfig
	if matrix == null:
		push_error("Configs: не удалось загрузить resources/configs/matrix.tres")

	smoke = load("res://resources/configs/smoke.tres") as SmokeConfig
	if smoke == null:
		push_error("Configs: не удалось загрузить resources/configs/smoke.tres")

	matrix_smoke = load("res://resources/configs/matrix_smoke.tres") as MatrixSmokeConfig
	if matrix_smoke == null:
		push_error("Configs: не удалось загрузить resources/configs/matrix_smoke.tres")

	words_v01 = load("res://resources/content/words_v01.tres") as WordsTable
	if words_v01 == null:
		push_error("Configs: не удалось загрузить resources/content/words_v01.tres (запусти Tools/convert_content.py)")

	sentences_v02 = load("res://resources/content/sentences_v02.tres") as SentencesTable
	if sentences_v02 == null:
		push_error("Configs: не удалось загрузить resources/content/sentences_v02.tres (запусти Tools/convert_content.py)")
