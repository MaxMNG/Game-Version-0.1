shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(0.35, 0.65, 1.0, 1.0);
uniform float intensity = 0.18;
uniform float line_frequency = 220.0;
uniform float ripple_speed = 1.6;

void fragment() {
	float band = 0.5 + 0.5 * sin(UV.y * line_frequency + TIME * ripple_speed);
	float ripple = 0.5 + 0.5 * sin((UV.x + UV.y) * 40.0 - TIME * ripple_speed * 2.0);
	float a = intensity * (0.35 + 0.65 * band * ripple);
	COLOR = vec4(line_color.rgb, line_color.a * a);
}
