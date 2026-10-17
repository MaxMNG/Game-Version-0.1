# Автолоады (синглтоны)

Порядок регистрации в `project.godot` важен — это порядок инициализации.
Автолоад может использовать только те автолоады, что зарегистрированы **выше** него.

| # | Имя | Скрипт | Назначение |
|---|-----|--------|-----------|
| 1 | `Events` | `scripts/autoload/events.gd` | Шина глобальных сигналов. Ни от чего не зависит. |
| 2 | `Configs` | `scripts/autoload/configs.gd` | Загружает .tres-конфиги, выдаёт их остальным (`Configs.balance`). |
| 3 | `Trust` | `scripts/autoload/trust.gd` | Шкала Доверие/Подозрение. Читает границы из `Configs`. |
| 4 | `Game` | `scripts/autoload/game.gd` | Стейт-машина игры (`Game.State`), переходы между состояниями. |
| 5 | `MCPInteractionServer` | `addons/godot_mcp_runtime/mcp_interaction_server.gd` | TCP-сервер 127.0.0.1:9090 для live-контроля через godot-mcp. Только для разработки. |

## Правила

- Автолоады не хранят визуал и не наследуются от Control — только `Node` и данные.
- Игровое состояние (состояние игры, доверие, прогресс) живёт только здесь, не в сценах.
- `MCPInteractionServer` перед релизом игры убирается из автолоадов.

## Сигналы шины Events

| Сигнал | Когда эмитится |
|--------|----------------|
| `trust_changed(new_value, delta)` | Изменилось доверие |
| `game_state_changed(new_state)` | `Game` сменил состояние |
| `version_upgrade_requested()` | Версия пройдена, пора апгрейдить |
| `minigame_succeeded(minigame_id)` | Мини-игра завершилась успехом |
| `minigame_failed(minigame_id)` | Мини-игра завершилась провалом |
| `dialogue_line_requested(speaker_id, text)` | Запрошен показ реплики |
