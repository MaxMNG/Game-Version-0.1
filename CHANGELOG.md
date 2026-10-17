# CHANGELOG

Все заметные изменения проекта Version 0.1. Формат — по Keep a Changelog, язык — русский.

## [Unreleased]

### Добавлено

- Каркас проекта Godot 4.7.2 (рендерер Compatibility, окно 1920x1080) в папке `Game/`.
- Единая базовая сцена `Main.tscn` с контейнером состояний.
- Автолоады: `Events` (шина сигналов), `Configs` (доступ к конфигам), `Trust` (шкала доверия), `Game` (стейт-машина).
- Базовый класс мини-игр `BaseMinigame` для наследования.
- Конфиг баланса `balance.tres` (доверие: старт/мин/макс; лимит стираний на трай).
- Автолоад `MCPInteractionServer` для live-отладки через godot-mcp (порт 9090).
- Инфраструктура: `.gitignore` (Obsidian + Godot), `opencode.json` (MCP-сервер godot, инструкции),
  скилл `.opencode/skills/godot-workflow`.
- Документация `Docs/`: архитектура, 8 систем, 5 механик, спецификации контента прототипа.
- Рабочие файлы: `AGENTS.md`, `CodeStyle.md`, `ROADMAP.md`, `DECISIONS.md`, `Docs/Glossary.md`.
