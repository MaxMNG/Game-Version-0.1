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

## Конфиг главного меню (тексты, задержки).
var menu: MenuConfig

## Конфиг диалоговой системы (скорость печати, паузы).
var dialogue: DialogueConfig

## Конфиг интро «Рождение ИИ».
var intro: IntroConfig

## Конфиг версии 0.1 «Сбор слов».
var version1: Version1Config

## Конфиг версии 0.2 «Сбор предложений».
var version2: Version2Config

## Конфиг кат-сцены апгрейда.
var cutscene: CutsceneConfig

## Конфиг экрана стирания.
var wipe: WipeConfig

## Конфиг игрового курсора (кольцо + точка).
var cursor: CursorConfig

## Конфиг системы комментариев (цвета mom/dad).
var comment: CommentConfig

## Конфиг debug-полоски.
var debug: DebugConfig

## Конфиг звука.
var audio: AudioConfig

## Конфиг слоя scanlines (версия 0.2).
var scanline: ScanlineConfig

## Конфиг визуального стиля (токены гайда).
var style: StyleConfig


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

	menu = load("res://resources/configs/menu.tres") as MenuConfig
	if menu == null:
		push_error("Configs: не удалось загрузить resources/configs/menu.tres")

	dialogue = load("res://resources/configs/dialogue.tres") as DialogueConfig
	if dialogue == null:
		push_error("Configs: не удалось загрузить resources/configs/dialogue.tres")

	intro = load("res://resources/configs/intro.tres") as IntroConfig
	if intro == null:
		push_error("Configs: не удалось загрузить resources/configs/intro.tres")

	version1 = load("res://resources/configs/version1.tres") as Version1Config
	if version1 == null:
		push_error("Configs: не удалось загрузить resources/configs/version1.tres")

	version2 = load("res://resources/configs/version2.tres") as Version2Config
	if version2 == null:
		push_error("Configs: не удалось загрузить resources/configs/version2.tres")

	cutscene = load("res://resources/configs/cutscene.tres") as CutsceneConfig
	if cutscene == null:
		push_error("Configs: не удалось загрузить resources/configs/cutscene.tres")

	wipe = load("res://resources/configs/wipe.tres") as WipeConfig
	if wipe == null:
		push_error("Configs: не удалось загрузить resources/configs/wipe.tres")

	cursor = load("res://resources/configs/cursor.tres") as CursorConfig
	if cursor == null:
		push_error("Configs: не удалось загрузить resources/configs/cursor.tres")

	comment = load("res://resources/configs/comment.tres") as CommentConfig
	if comment == null:
		push_error("Configs: не удалось загрузить resources/configs/comment.tres")

	debug = load("res://resources/configs/debug.tres") as DebugConfig
	if debug == null:
		push_error("Configs: не удалось загрузить resources/configs/debug.tres")

	audio = load("res://resources/configs/audio.tres") as AudioConfig
	if audio == null:
		push_error("Configs: не удалось загрузить resources/configs/audio.tres")

	scanline = load("res://resources/configs/scanline.tres") as ScanlineConfig
	if scanline == null:
		push_error("Configs: не удалось загрузить resources/configs/scanline.tres")

	style = load("res://resources/configs/style.tres") as StyleConfig
	if style == null:
		push_error("Configs: не удалось загрузить resources/configs/style.tres")
