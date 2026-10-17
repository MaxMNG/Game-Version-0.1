// Фон «Кольцо-эквалайзер» (этап 1 работы над фоном, референс — Небула1.jpg).
// Кольцо радиальных баров: длина бара — чистая функция времени (база + шум),
// поэтому «возврат на место» после магнита курсора происходит сам.
// Все параметры приходят из RingConfig через скрипт ring_background.gd;
// значения по умолчанию — только fallback для превью.
shader_type canvas_item;

// Встроенные константы TAU и PI используем как есть.

uniform vec4 color_a : source_color = vec4(0.2, 0.95, 1.0, 1.0);
uniform vec4 color_b : source_color = vec4(0.3, 1.0, 0.55, 1.0);
uniform vec4 color_c : source_color = vec4(1.0, 0.25, 0.9, 1.0);

uniform int bar_count = 150;
uniform float ring_radius = 0.34;
uniform float bar_base_length = 0.02;
uniform float bar_span = 0.1;
uniform float bar_width = 0.7;
uniform float bar_length = 100.0;
uniform float glow_strength = 0.6;
uniform float rotation_speed = 0.02;

uniform float inner_jitter_amount = 0.6;
uniform float inner_jitter_speed = 0.4;

uniform float alpha_min = 0.35;
uniform float alpha_speed = 0.5;
uniform float bar_opacity = 1.0;

uniform float gradient_sharp = 1.5;

uniform float jitter_amount = 0.8;
uniform float jitter_speed = 0.6;

uniform vec2 cursor_uv = vec2(0.5, 0.5);
uniform float magnet_strength = 0.0;
uniform float magnet_radius = 0.22;
uniform float magnet_lift = 0.08;
uniform float magnet_strength_max = 1.0;
uniform float magnet_visibility_boost = 0.5;

uniform float brightness = 1.0;
// Появление из темноты: 0 — чёрный экран, 1 — полностью видно.
uniform float appear = 1.0;
// Отношение ширины к высоте вьюпорта; обновляется скриптом при изменении размера.
uniform float aspect = 1.7778;

// Хэш для 1D-шума дрожания баров.
float hash11(float p) {
	vec3 p3 = fract(vec3(p) * 0.1031);
	p3 += dot(p3, p3.zyx + 31.32);
	return fract((p3.x + p3.y) * p3.z);
}

// 1D value noise с плавной интерполяцией.
float vnoise1(float x) {
	float i = floor(x);
	float f = fract(x);
	float u = f * f * (3.0 - 2.0 * f);
	return mix(hash11(i), hash11(i + 1.0), u);
}

void fragment() {
	// Полярные координаты от центра экрана (аспект-корректные).
	vec2 pc = vec2((UV.x - 0.5) * aspect, UV.y - 0.5);
	float rad = length(pc);
	float ang = atan(pc.y, pc.x);
	float a = ang + TIME * rotation_speed;

	// Номер бара и доля внутри сектора.
	float slices = float(bar_count);
	float f = (a / TAU + 0.5) * slices;
	float idx = floor(f);
	float sector_frac = abs(fract(f) - 0.5) * 2.0;

	// Дрожание: два слоя шума по индексу бара, 0..1.
	float wobble = vnoise1(idx * 0.717 + TIME * jitter_speed) * 0.6
			+ vnoise1(idx * 1.313 - TIME * jitter_speed * 0.7) * 0.4;
	float len = bar_base_length
			+ bar_span * (1.0 - jitter_amount * 0.5 + jitter_amount * (wobble - 0.5));

	// Магнит курсора: гауссиана по угловой дистанции (в тех же единицах, что радиус).
	vec2 cc = vec2((cursor_uv.x - 0.5) * aspect, cursor_uv.y - 0.5);
	float c_rad = length(cc);
	float cursor_ang = atan(cc.y, cc.x) + TIME * rotation_speed;
	float ang_dist = abs(mod(a - cursor_ang + PI, TAU) - PI);
	float magnet = exp(-pow(ang_dist * max(rad, 0.05), 2.0)
			/ max(magnet_radius * magnet_radius, 0.0001)) * magnet_strength;
	// Магнит работает только рядом с полосой баров: в глубине круга
	// и далеко снаружи курсор бары не трогает.
	float band_center = ring_radius + bar_span * 0.5;
	float radial_far = abs(c_rad - band_center);
	float prox = 1.0 - smoothstep(0.0, magnet_radius * 1.5, radial_far);
	magnet *= prox * prox;
	len += magnet_lift * magnet;
	// Общая длина баров (0..100): при 0 бары практически исчезают.
	len *= bar_length / 100.0;

	// Внутренняя граница тоже дышит: отдельный шум, своя скорость.
	float inner_wobble = vnoise1(idx * 1.917 + 5.0 - TIME * inner_jitter_speed) * 0.6
			+ vnoise1(idx * 0.613 + 11.0 + TIME * inner_jitter_speed * 0.7) * 0.4;
	float r0 = ring_radius + (inner_wobble - 0.5) * inner_jitter_amount * bar_span;
	float r1 = ring_radius + len;
	float in_rad = smoothstep(r0 - 0.004, r0 + 0.004, rad)
			* (1.0 - smoothstep(r1 - 0.004, r1 + 0.004, rad));
	float in_ang = 1.0 - smoothstep(bar_width - 0.06, bar_width + 0.06, sector_frac);
	// Неоднородная прозрачность: каждый бар дышит со своей фазой.
	// bar_opacity — общая прозрачность всех баров (в 0 гасит их полностью).
	float alpha_i = mix(alpha_min, 1.0,
			0.5 + 0.5 * vnoise1(idx * 2.173 + 3.0 + TIME * alpha_speed));
	float bar = in_rad * in_ang * alpha_i * bar_opacity;

	// Мягкое свечение вокруг кольца.
	float glow = exp(-pow(rad - ring_radius - 0.05, 2.0) / 0.02) * glow_strength;

	// Градиент по кругу: три мягкие косинусные «шапки» (A → B → C → A).
	// Нормировка убирает швы полностью; gradient_sharp задаёт мягкость переходов.
	float t = fract(a / TAU + 0.5);
	float wA = pow(0.5 + 0.5 * cos(TAU * t), gradient_sharp);
	float wB = pow(0.5 + 0.5 * cos(TAU * (t - 1.0 / 3.0)), gradient_sharp);
	float wC = pow(0.5 + 0.5 * cos(TAU * (t - 2.0 / 3.0)), gradient_sharp);
	vec3 col123 = (color_a.rgb * wA + color_b.rgb * wB + color_c.rgb * wC)
			/ max(wA + wB + wC, 0.001);

	// Магнит не только тянет, но и делает бары заметнее (доля от magnet_visibility_boost).
	float magnet_norm = clamp(magnet / max(magnet_strength_max, 0.001), 0.0, 1.5);
	float excite = 1.0 + magnet_visibility_boost * magnet_norm;
	vec3 col = col123 * (bar * 1.2 + glow * 0.5) * excite;

	COLOR = vec4(col * brightness * appear, 1.0);
}
