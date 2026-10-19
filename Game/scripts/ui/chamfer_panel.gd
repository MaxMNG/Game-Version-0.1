class_name ChamferPanel
extends PanelContainer
## Панель со срезанными углами по гайду (`03_ui_kit.md`).
##
## Рисует заливку `surface` с прозрачностью и контур 1–2 px
## со срезом по диагонали (левый-верхний и правый-нижний).
## Все числа — из `Configs.style` (ноль хардкода в коде).

## Большой срез (переопределяет конфиг, если >= 0).
@export var chamfer_override: int = -1
## Цвет рамки (по умолчанию `line`; активное — ставить `cyan`/`blue` из кода).
@export var frame_color: Color = Color(0, 0, 0, 0)
## Заливка панели (по умолчанию `surface` с альфой конфига).
@export var fill_color: Color = Color(0, 0, 0, 0)
## Показывать скобки-маркеры фокуса по углам.
@export var show_focus_marks: bool = false


func _ready() -> void:
	# Панель не перехватывает клики мимо кнопок внутри.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var st: StyleConfig = Configs.style if Configs != null else null
	var cut: int = chamfer_override if chamfer_override >= 0 else (st.chamfer_size if st != null else 16)
	var lw: float = float(st.line_width) if st != null else 2.0
	var frame: Color = frame_color
	if frame.a <= 0.0:
		frame = st.col_line if st != null else Color("#25495F")
	var fill: Color = fill_color
	if fill.a <= 0.0:
		var base: Color = st.col_surface if st != null else Color("#0F1722")
		var alpha: float = st.panel_fill_alpha if st != null else 0.72
		fill = Color(base.r, base.g, base.b, alpha)
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	# Контур со срезом: верхний-левый и нижний-правый углы срезаны.
	var pts: PackedVector2Array = PackedVector2Array([
		rect.position + Vector2(cut, 0),
		rect.position + Vector2(rect.size.x, 0),
		rect.position + Vector2(rect.size.x, rect.size.y - cut),
		rect.position + Vector2(rect.size.x - cut, rect.size.y),
		rect.position + Vector2(0, rect.size.y),
		rect.position + Vector2(0, cut),
		rect.position + Vector2(cut, 0),
	])
	draw_colored_polygon(PackedVector2Array([
		pts[0], pts[1], pts[2], pts[3], pts[4], pts[5],
	]), fill)
	draw_polyline(pts, frame, lw, true)
	if show_focus_marks:
		var mark_col: Color = st.col_cyan if st != null else Color("#59D0F3")
		var m: float = 10.0
		# Две скобки по срезанным углам.
		draw_line(pts[0], pts[0] + Vector2(m, 0), mark_col, lw + 1.0, true)
		draw_line(pts[5], pts[5] + Vector2(0, m), mark_col, lw + 1.0, true)
