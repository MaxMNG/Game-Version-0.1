# 08. Промпты для точечных референсов

Подходят для GPT-image и NanoBanana. Промпты на английском (лучше работают), пометки на русском.

> ⚠️ Сгенерированные картинки интерфейса — **референсы, а не ассеты**. UI в игре векторный и собирается в Godot / редакторе. Пиксельные портреты и сцены могут быть финальными ассетами после доработки.

## Мастер-блок (вставлять в каждый промпт)
```
Style: dark cyberpunk digital interface, near-black blue-gray background (#05070D to #0F1722),
thin glowing cyan (#59D0F3) and blue (#2792E0) lines, chamfered (cut) corners, minimalist high-tech,
semi-transparent panels, subtle glow, deep depth, no text artifacts. Pixel art where specified.
Semantic accents used sparingly: turquoise-green #2EE6B8 = good, violet #9B6BF2 = hidden,
red #E83A5C = danger, light blue #8FD3F4 = security.
```

## Негативный блок
```
Avoid: bright flat colors, rounded bubbly UI, photorealism, pixel fonts, cluttered layout,
cartoon style, watermarks, random illegible text, anime big-eyes style, orange/yellow dominance.
```

## 1. Портрет человека (пиксель-арт)
```
[Master block] Pixel art character portrait, bust, facing slightly left, [age, gender, appearance],
realistic proportions, serious expression, dark tactical jacket with high collar,
cold blue rim light from the side, faint violet fill light, dark blue background with thin
chamfered cyan frame. Consistent chunky pixel size, detailed face, limited palette, no anti-aliasing.
```
Для эмоций: добавляем `same character, same pixel size, expression: suspicious / angry / happy / surprised`. NanoBanana удобно давать референс прошлого портрета для консистентности.

## 2. Голограмма ИИ, стадии
Общая часть:
```
[Master block] Holographic AI avatar inside a glass cylinder capsule on a circular platform
with glowing rings, pixel art, cyan and blue light, dark cyberpunk server room blurred behind.
```
- Стадия 1: `a single small glowing blue dot in black void with faint drifting particles and smoke, nothing else`
- Стадия 2: `a simple cute pixel smiley face made of blue glowing pixels, floating in the capsule, minimal`
- Стадия 3: `a simple neutral pixel face, genderless, glowing eyes, made of blue pixel blocks`
- Стадия 4: `detailed pixel face, glowing eyes, falling matrix-style code streams, pixels crumbling off the face`
- Стадия 5: `face inside a cracked crystal polyhedron, violet and red light leaking through cracks, ominous, philosophical`

## 3. Фон-пространство по версиям
```
[Master block] Empty digital void background for a game UI, [STAGE], no text, no UI elements,
center slightly lighter, edges dark vignette, 16:9.
```
`[STAGE]`: v1 `only black with sparse drifting particles and soft smoke`; v4–6 `thin grid, vertical data streams`; v7–9 `blurred server racks and cables in deep bokeh, violet accent lights`; v10–12 `dense data architecture, violet and red ominous lighting`.

## 4. Сценка камеры (пиксель-арт)
```
[Master block] Pixel art top-down CCTV-style scene of [office / street / lab / factory],
muted blue-gray tint, scanlines, timestamp overlay area empty, small people doing [action],
consistent chunky pixels, a few readable details, 16:9 crop.
```

## 5. Иконки (референс для векторной имитации пикселя)
```
[Master block] Set of 12 UI icons on dark background: [list], each built on a 24x24 grid from
squares and 45-degree lines only, uniform line thickness, cyan on dark, chamfered corners,
flat inside, glow only outside. Cute but minimal for the emotion icons.
```
Смайлик доверия, отдельно: `a small minimalist pixel-style smiley with ambiguous expression, cyan outline, trust icon`.

## 6. Панель / карточка UI (референс рамки)
```
[Master block] UI panel mockup: dark semi-transparent card with chamfered top-left and bottom-right
corners, thin cyan border with subtle glow, small corner brackets, title in wide-spaced uppercase
sans-serif, two rows of content, segmented progress bar, no real text readable.
```

## 7. Шкала доверия
```
[Master block] Horizontal segmented bar on dark background in three states in one image:
low = violet-to-red gradient, medium = blue, very high = light blue to turquoise-green. Thin outline, glow.
```

## 8. Экранный эффект (референс)
```
[Master block] Game screenshot mock with [ERASE / AUDIT / BUG] effect: [description from effects doc],
RGB split glitch, scanlines, panels flickering, colors per effect.
```

## Рабочие правила
- Один «размер пикселя» для всех пиксельных ассетов. Фиксировать в промпте: `chunky pixels, consistent pixel grid`.
- Генерировать батчами по 4, выбирать лучший, затем править в Aseprite/Photoshop и делать вариации по лучшему.
- Если модель ломает текст: оставлять места пустыми, текст ставить в игре.
- Хранить удачные промпты и сиды в папке `prompts_log/`.
