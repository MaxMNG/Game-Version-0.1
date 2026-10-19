class_name TrustBar
extends Control
## Сегментированная полоска доверия по гайду (`03_ui_kit.md`).
##
## Заливка сегментов цветом по уровню (палитра `01_palette.md`):
## низко — градиент `hidden` → `danger`, середина — `blue`,
## высоко — `safe` → `good`. Все цвета — из `Configs.style`.

## Минимум шкалы.
var min_value: int = -100
## Максимум шкалы.
var max_value: int = 100
## Текущее значение.
var value: int = 0
## Число сегментов.
var segments: int = 20


## Обновить бар (перерисовка).
func set_bar(p_min: int, p_max: int, p_value: int, p_segments: int) -> void:
	min_value = p_min
	max_value = p_max
	value = clampi(p_value, p_min, p_max)
	segments = maxi(1, p_segments)
	custom_minimum_size = Vector2(float(segments) * 10.0, 14.0)
	queue_redraw()


func _draw() -> void:
	if Configs == null or Configs.style == null:
		return
	var st: StyleConfig = Configs.style
	var frac: float = 0.5
	if max_value > min_value:
		frac = float(value - min_value) / float(max_value - min_value)
	var filled: int = int(round(frac * float(segments)))
	var gap: float = 3.0
	var seg_w: float = (size.x - gap * float(segments - 1)) / float(segments)
	var h: float = size.y
	for i: int in segments:
		var x: float = float(i) * (seg_w + gap)
		var r: Rect2 = Rect2(x, 0.0, seg_w, h)
		if i < filled:
			draw_rect(r, _level_color(frac, st))
		else:
			draw_rect(r, st.col_line_dim)


## Цвет заливки по уровню шкалы (см. палитру).
func _level_color(frac: float, st: StyleConfig) -> Color:
	if frac < 0.25:
		return st.col_hidden.lerp(st.col_danger, frac / 0.25)
	elif frac < 0.45:
		return st.col_danger.lerp(st.col_blue, (frac - 0.25) / 0.2)
	elif frac < 0.65:
		return st.col_blue
	elif frac < 0.85:
		return st.col_blue.lerp(st.col_safe, (frac - 0.65) / 0.2)
	return st.col_safe.lerp(st.col_good, (frac - 0.85) / 0.15)
