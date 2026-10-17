extends Control
## Лабораторный «прицел»: рисует позицию мыши так, как её видит Godot.
##
## Помогает работать с панелью настроек и диагностировать расхождение
## системного курсора с координатами вьюпорта (масштаб ОС/окно).

const RADIUS: float = 9.0


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var pos: Vector2 = get_global_mouse_position()
	draw_arc(pos, RADIUS, 0.0, TAU, 24, Color(1.0, 1.0, 1.0, 0.9), 2.0)
	draw_arc(pos, RADIUS + 2.0, 0.0, TAU, 24, Color(0.0, 0.0, 0.0, 0.9), 1.0)
	draw_circle(pos, 1.5, Color(1.0, 1.0, 1.0, 0.9))
