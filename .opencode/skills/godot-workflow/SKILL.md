---
name: Godot Workflow
description: Регламент работы с Godot-проектом Version 0.1 — запуск, валидация скриптов, отладка запущенной игры через godot-mcp. Использовать при любых задачах внутри папки Game/.
---

# Регламент работы с Godot-проектом

## Пути

- Проект Godot: `Game/` (файл `Game/project.godot`)
- Движок: `F:/GODOT/Godot_v4.7.2-stable_win64_console.exe` (консольная сборка — видно вывод)
- MCP-сервер: `godot` (godot-mcp v3.1.0, настроен в `opencode.json`)

## Правила

1. Никаких числовых литералов в коде — все балансные числа живут в `Game/resources/configs/*.tres` (требование GDD).
2. Перед коммитом изменений в `Game/` всегда прогонять валидацию (см. ниже).
3. Стиль кода — только по `CodeStyle.md`.
4. Общение между системами — через сигналы автолоада `Events`, не напрямую.

## Валидация после изменений кода

```powershell
# Импорт ресурсов (после добавления новых файлов)
F:/GODOT/Godot_v4.7.2-stable_win64_console.exe --headless --path Game --import

# Дымовой тест: запуск на несколько кадров, ошибки парсинга будут в выводе
F:/GODOT/Godot_v4.7.2-stable_win64_console.exe --headless --path Game --quit-after 5
```

## Отладка запущенной игры через godot-mcp

1. Запустить игру: инструмент MCP `run_project` (автолоад `MCPInteractionServer` поднимет TCP на 127.0.0.1:9090).
2. Дальше — runtime-инструменты: `game_eval` (произвольный GDScript), `game_get_node_info`, `game_set_property`, `game_screenshot` и т.д.
3. После отладки остановить игру (`kill` процесса или `game_eval` с `get_tree().quit()`).

## Чеклист перед сдачей задачи

- [ ] `--import` и дымовой тест проходят без ошибок парсинга
- [ ] Новые числа вынесены в конфиги, а не захардкожены
- [ ] Обновлены затронутые документы в `Docs/` и `CHANGELOG.md`
- [ ] AGENTS.md актуален (если менялась структура/команды)
