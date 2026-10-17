# Skill: Godot Effect

# Чеклист создания нового визуального эффекта (фон, вспышка, переход).
# Порядок обязателен, пропуск шагов — только по явной просьбе пользователя.

1. Конфиг: `Game/scripts/resources/<name>_config.gd` (`class_name XxxConfig`,
   русские docstring-комментарии, группы `@export_group`) +
   `Game/resources/configs/<name>.tres`.
2. Шейдер: `Game/assets/shaders/<name>.gdshader`. Имена uniform не должны
   совпадать с именами параметров функций (ошибка компиляции `Redefinition`).
   Парные константы шейдер↔скрипт (`MAX_OCTAVES` и т.п.) — держать синхронно,
   со ссылкой в комментарии с обеих сторон.
3. Скрипт: `Game/scripts/effects/<name>.gd`, контракт: `apply_config()`,
   `set_muted()`, `set_reveal()` / `play_appearance()`, `mouse_filter = IGNORE`.
   Прозрачность — только через альфу выхода шейдера, не через `modulate`.
   Если эффект комбинирует готовые сцены — дублировать их материалы
   (`duplicate()`), общий SubResource-материал шарится между инстансами.
4. Сцена: `Game/scenes/effects/<name>.tscn` (зеркало существующих сцен эффектов).
   `unique_name_in_owner` на корне инстанса не работает — для доступа из скрипта
   оборачивать инстансы в Holder-контейнеры с уникальным именем.
5. Регистрация в `Game/scripts/autoload/configs.gd` (поле + `load` + проверка на null).
6. Панель в лаборатории (`background_lab.gd`): `_config_for()` + `_build_<name>_panel()`,
   кнопка в `background_lab.tscn`. Не более 20 ручек.
7. Проверки: `--import` + прогон **каждой** тронутой сцены отдельно
   (`--quit-after 10`), а не только главной (команды — в `AGENTS.md`).
8. Доки: `ROADMAP.md` (сразу после этапа, не в конце сессии),
   `Docs/Prototype/plan.md`, `CHANGELOG.md`.
   Настроенные геймдизайнером `.tres` не сбрасывать к дефолтам без спроса.
