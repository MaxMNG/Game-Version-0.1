class_name FlashOverlay
extends ColorRect
## Полноэкранная вспышка (белая, быстрая).
##
## Используется интро, апгрейдом и стиранием. После завершения — сигнал.

## Вспышка завершена.
signal flash_finished


## Показать вспышку длительностью из конфига (сек).
func flash(duration: float) -> void:
	visible = true
	color = Color(1, 1, 1, 1)
	var tween: Tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, duration)
	tween.tween_callback(_on_flash_done)


func _on_flash_done() -> void:
	visible = false
	flash_finished.emit()
