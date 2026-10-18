# Аудио прототипа

## Статус
Процедурные SFX уже работают кодом (`Audio`: click/success/fail).
Музыка — плейсхолдер: `Audio.start_music(&"v01"|&"v02")` ищет файлы
`music_v01.ogg` / `music_v02.ogg` рядом и молчит, если их нет.

## DAICE (проверено 2026-10-18, только чтение)
`D:/Games/DAICE/dAIce_Data` — Unity-билд: `data.unity3d`,
`sharedassets*.resource`, Addressables в `StreamingAssets/aa`.
Отдельных `.ogg/.wav/.mp3/.bank` нет — звук упакован.
Извлечение требует распаковщика Unity-ассетов — откладываем;
если пользователь извлечёт файлы сам — положим их сюда как
`music_v01.ogg` / `music_v02.ogg` (+ SFX при желании).

## Временная замена (CC0)
Скачать CC0-пак (например, Kenney UI Audio + ambient-луп с freesound.org)
и положить сюда. Лицензию указать в этом файле.
