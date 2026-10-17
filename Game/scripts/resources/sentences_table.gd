class_name SentencesTable
extends Resource
## Обёртка-таблица наборов предложений версии 0.2: ресурс с массивом `SentenceEntry`.
##
## Одна строка CSV — одно валидное предложение; строки с одним `set_id`
## описывают один набор слов (список слов набора объединяется конвертером).
## Загружается автолоадом `Configs` из `resources/content/sentences_v02.tres`.

## Все записи таблицы предложений (со всех наборов).
@export var entries: Array[SentenceEntry] = []


## Все предложения одного набора (порядок как в CSV).
## Возвращает пустой массив, если набора с таким id нет.
func get_set(set_id: String) -> Array[SentenceEntry]:
	var result: Array[SentenceEntry] = []
	for entry: SentenceEntry in entries:
		if entry.set_id == set_id:
			result.append(entry)
	return result


## Является ли строка валидным предложением набора (сравнение без учёта регистра).
func is_valid_sentence(set_id: String, sentence: String) -> bool:
	var target: String = sentence.strip_edges().to_lower()
	for entry: SentenceEntry in get_set(set_id):
		if entry.sentence.strip_edges().to_lower() == target:
			return true
	return false
