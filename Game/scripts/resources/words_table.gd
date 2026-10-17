class_name WordsTable
extends Resource
## Обёртка-таблица слов версии 0.1: ресурс с массивом `WordEntry`.
##
## Загружается автолоадом `Configs` из `resources/content/words_v01.tres`.

## Все записи таблицы слов.
@export var entries: Array[WordEntry] = []


## Найти запись по слову (сравнение без учёта регистра).
## Возвращает null, если слова в таблице нет.
func get_by_word(word: String) -> WordEntry:
	var target: String = word.to_upper()
	for entry: WordEntry in entries:
		if entry.word == target:
			return entry
	return null
