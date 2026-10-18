class_name ScanlineBackground
extends ColorRect
## Слой scanlines/ripple поверх фона для версии 0.2.
##
## Параметры читаются из `Configs.scanline`, клики пропускает.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_apply_config()


func _apply_config() -> void:
	if Configs.scanline == null:
		return
	var mat: ShaderMaterial = material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("line_color", Configs.scanline.line_color)
	mat.set_shader_parameter("intensity", Configs.scanline.intensity)
	mat.set_shader_parameter("line_frequency", Configs.scanline.line_frequency)
	mat.set_shader_parameter("ripple_speed", Configs.scanline.ripple_speed)
