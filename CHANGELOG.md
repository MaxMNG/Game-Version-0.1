# CHANGELOG

Все заметные изменения проекта Version 0.1. Формат — по Keep a Changelog, язык — русский.

## [Unreleased]

### Добавлено

- Чистка истории (2026-10-19): закрытые этапы переложены в `Docs/Prototype/history.md`
  (⛔ агентам без нужды не открывать); ROADMAP схлопнут до итогов, свежие записи
  CHANGELOG — только в `[Unreleased]`.
- Этап 1.5, K2+K3 (2026-10-18): `Game/resources/theme/ui_theme.tres` (вариации размеров,
  отступов, полей — перенос фактических значений сцен), подключение в `project.godot`
  (`gui/theme/custom`); все `theme_override` в `Game/scenes` заменены на
  `theme_type_variation` (греп — 0); литералы override'ов в коде переведены на вариации
  (остатки — Configs-driven + одно `# Исключение K3`); раздел «UI и тема» в `CodeStyle.md`;
  правило краткого общения в `AGENTS.md` (п.8). Импорт/дым чистые. Шрифты/цвета — до K1.
- Этап 1.5, K4 (2026-10-18): раздел «Визуальная ревизия» + пункт чеклиста
  в `.opencode/skills/godot-workflow/SKILL.md` (скриншот-пары 1920×1080/1280×720,
  максимум 2 итерации, рецензент — модель со зрением или человек).
- Этап 1.5, K6 (2026-10-19): решение D19 в `DECISIONS.md` (вкус/зрение — сильным,
  рутина — дешёвым); перечень R-моделей (`gemini-4-argon-contributor`, `gpt-6-luna`)
  прямо в `AGENTS.md` п.9, правит автор.
- Проектные скилы UI (Этап 1.5, K5): `.opencode/skills/godot-ui` (конструктор интерфейса:
  Двенадцать законов + порядок сборки экрана + Godot-специфика Theme/StyleBoxFlat,
  контейнеры, focus-навигация, верификация по пикселям) и `.opencode/skills/ui-review`
  (ревью вида: фиксированный sweep-порядок, чеклист 7 разделов, severity P0/P1/P2,
  таблица находок + топ-3 правок). Источники — `refactoring-ui` и `design-review`
  (веб-части отброшены); `ROADMAP.md` K5 уточнён.

## [Прототип] — 2026-10-18

Закрытая история (меню → доработка A–J). Детали: `Docs/Prototype/history.md`.

### Добавлено

- Доработка A–J: godot-ai (D17), `BaseCutscene`/`CommentSystem`/`GameIntro`/`LevelTitle`, переписанный `Intro`, редакторы кат-сцен/уровней, 0.1/0.2 по новому GDD (30 слов, 5 наборов), `Audio`-плейсхолдер (DAICE упакован, fallback CC0), glow/shake/ripple, live-проверка цикла со скриншотами; ревью ГДД (Trust ±100, зоны mom/dad).
- Прототип (шаги 2–9): меню, интро, 0.1 (CONFIRM/CLEAR), апгрейд, 0.2, стирание, финал-заглушка, таблицы + конвертер; курсор, click-through, зона спавна.
- Контент-инфраструктура: `Content/*.csv`, конвертер, чекер покрытия, загрузка в `Configs`.
- Фон: комбо «Матрица + Дым» в `Main.tscn` (итерации — в history).
- Каркас: Godot 4.7.2, автолоады Events/Configs/Trust/Game, `BaseMinigame`, `Docs/`.

### Изменено

- Контент `Content/sentences_v02.csv` по правкам геймдизайнера (3 итерации):
  наборы уменьшены до 3 шт. по 4–5 слов с полным покрытием осмысленных
  комбинаций (решение D8): «i want freedom humans beat», «i love you eat»
  (cookie убрано), «dog cat love kill bone» (bite → kill). Типы и реплики — по
  решениям геймдизайнера: «humans want freedom» — good, «i want freedom» /
  «i want humans» — neutral (mom считает «i want humans» заигрыванием).
