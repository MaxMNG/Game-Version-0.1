extends Node
## Шина глобальных сигналов игры.
##
## Все системы общаются друг с другом только через эти сигналы,
## чтобы не создавать прямых зависимостей между сценами и автолоадами.

# --- Доверие ---
## Изменилось доверие людей к ИИ.
signal trust_changed(new_value: int, delta: int)

# --- Жизненный цикл игры ---
## Игра перешла в новое состояние (см. Game.State).
signal game_state_changed(new_state: int)
## Игрок прошёл текущую версию, начинается апгрейд до следующей.
signal version_upgrade_requested()

# --- Мини-игры ---
## Мини-игра завершилась успехом.
signal minigame_succeeded(minigame_id: StringName)
## Мини-игра завершилась провалом.
signal minigame_failed(minigame_id: StringName)

# --- Диалоги ---
## Запрошен показ реплики персонажа (см. систему диалогов).
signal dialogue_line_requested(speaker_id: StringName, text: String)
