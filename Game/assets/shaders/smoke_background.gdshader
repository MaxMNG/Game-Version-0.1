// Фон «Дымка-lite» (этап 3 работы над фоном): лёгкий серо-голубой дым.
// Два слоя fbm с domain-warp, гравитация стягивает дым к центру композиции,
// виньетка гасит края. Курсор разгоняет дым (радиальный пуш + завихрение).
// Все параметры приходят из SmokeConfig через скрипт smoke_background.gd;
// значения по умолчанию — только fallback для превью.
// Ограничение GLSL ES (Compatibility): граница цикла — константа.
shader_type canvas_item;

// Лимит октав — должен совпадать с MAX_OCTAVES в smoke_background.gd.
const int MAX_OCTAVES = 5;

// Масштаб сдвига UV от возмущения курсора (форма эффекта; амплитуда — cursor_strength).
const float CURSOR_PUSH_SCALE = 0.1;

uniform vec4 background_color : source_color = vec4(0.02, 0.025, 0.045, 1.0);
uniform vec4 layer1_color : source_color = vec4(0.35, 0.45, 0.6, 1.0);
uniform vec4 layer2_color : source_color = vec4(0.55, 0.65, 0.8, 1.0);
// Общая сила цветовых слоёв поверх фона (защита от «навязчивости»).
uniform float accent_intensity = 0.35;

uniform float noise_scale = 3.0;
uniform int octave_count = 3;
uniform float evolution_speed = 0.05;
uniform float warp_amount = 0.7;
// Расширение контраста шума (value noise по умолчанию даёт «туманный» диапазон).
uniform float noise_contrast = 2.2;

// Гравитация: дым стягивается к центру композиции пропорционально шуму.
uniform vec2 gravity_center = vec2(0.5, 0.5);
uniform float gravity_strength = 0.35;

// Плотность слоёв и виньетки.
uniform float layer1_strength = 0.5;
uniform float layer2_strength = 0.45;
uniform float vignette_strength = 0.5;

// Возмущение от курсора; сила обновляется скриптом каждый кадр.
uniform vec2 cursor_uv = vec2(0.5, 0.5);
uniform float cursor_radius = 0.22;
uniform float cursor_strength = 0.0;
uniform float cursor_swirl = 0.55;

uniform float brightness = 1.0;
// Появление из темноты: 0 — чёрный экран, 1 — полностью видно.
uniform float appear = 1.0;
// Доля видимости слоя (1 — непрозрачный соло-режим; комбо ставит меньше).
uniform float amount = 1.0;
// Отношение ширины к высоте вьюпорта; обновляется скриптом при изменении размера.
uniform float aspect = 1.7778;

// Хэш для value noise (алгоритм Dave Hoskins).
float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// Value noise с плавной интерполяцией внутри ячейки.
float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 smooth_f = f * f * (3.0 - 2.0 * f);
	float top_left = hash12(cell);
	float top_right = hash12(cell + vec2(1.0, 0.0));
	float bottom_left = hash12(cell + vec2(0.0, 1.0));
	float bottom_right = hash12(cell + vec2(1.0, 1.0));
	return mix(mix(top_left, top_right, smooth_f.x),
			mix(bottom_left, bottom_right, smooth_f.x), smooth_f.y);
}

// fbm: суммирование октав с падающей амплитудой, нормированное в 0..1.
float fbm(vec2 p, int octaves) {
	float value = 0.0;
	float amplitude = 0.5;
	float max_amplitude = 0.0;
	for (int i = 0; i < MAX_OCTAVES; i++) {
		if (i >= octaves) {
			break;
		}
		value += amplitude * value_noise(p);
		max_amplitude += amplitude;
		p = p * 2.0 + vec2(17.3, 9.1);
		amplitude *= 0.5;
	}
	return value / max(max_amplitude, 0.0001);
}

// Расширение контраста: растягивает узкий фактический диапазон fbm в 0..1.
float contrast_expand(float n, float contrast) {
	return clamp((n - 0.5) * contrast + 0.5, 0.0, 1.0);
}

void fragment() {
	// Аспект-корректные координаты, чтобы клубы не сплющивались по горизонтали.
	vec2 p = vec2(UV.x * aspect, UV.y);
	float t = TIME * evolution_speed;

	// Возмущение от курсора: гауссово затухание + радиальный пуш с завихрением.
	vec2 cursor_pos = vec2(cursor_uv.x * aspect, cursor_uv.y);
	vec2 to_cursor = p - cursor_pos;
	float dist = length(to_cursor);
	float falloff = exp(-(dist * dist) / max(cursor_radius * cursor_radius, 0.0001));
	vec2 dir = vec2(0.0);
	if (dist > 0.00001) {
		dir = to_cursor / dist;
	}
	vec2 perp = vec2(-dir.y, dir.x);
	float center_fade = smoothstep(0.0, cursor_radius * 0.35, dist);
	p += (dir + perp * cursor_swirl) * falloff * center_fade
			* cursor_strength * CURSOR_PUSH_SCALE;

	// Гравитация к центру: тянем координаты к центру сильнее там, где гуще дым.
	vec2 center_pos = vec2(gravity_center.x * aspect, gravity_center.y);
	vec2 to_center = center_pos - p;
	float center_dist = length(to_center);
	vec2 grav_dir = vec2(0.0);
	if (center_dist > 0.00001) {
		grav_dir = to_center / center_dist;
	}
	float grav_prelim = fbm(p * noise_scale * 0.8 + vec2(3.0, 8.0), octave_count);
	p += grav_dir * grav_prelim * gravity_strength * 0.35;

	// Слой 1: крупный, медленный дрейф; warp-фаза тоже эволюционирует.
	vec2 q1 = p * noise_scale + vec2(t, -t * 0.7);
	float warp1 = fbm(q1 * 0.5 + vec2(11.0, 3.0) + vec2(t * 0.3, -t * 0.2), octave_count) - 0.5;
	float n1 = contrast_expand(fbm(q1 + warp1 * warp_amount * 2.0, octave_count), noise_contrast);

	// Слой 2: средний, дрейф в другую сторону.
	vec2 q2 = p * noise_scale * 1.8 + vec2(-t * 1.3, t * 0.9) + vec2(31.0, 7.0);
	float warp2 = fbm(q2 * 0.5 + vec2(5.0, 19.0), octave_count) - 0.5;
	float n2 = contrast_expand(fbm(q2 + warp2 * warp_amount * 2.0, octave_count), noise_contrast);

	// Сборка: фон → первый слой → второй слой → светлые «прожилки».
	vec3 col = background_color.rgb;
	col = mix(col, layer1_color.rgb, pow(smoothstep(0.45, 0.9, n1), 1.5) * layer1_strength);
	col = mix(col, layer2_color.rgb, pow(smoothstep(0.55, 0.85, n2), 1.5) * layer2_strength);
	float highlight = pow(smoothstep(0.7, 0.95, n2), 2.0);
	col += layer2_color.rgb * highlight * 0.25;

	// Виньетка: мягкое затемнение краёв держит композицию в центре.
	float vig = 1.0 - vignette_strength
			* smoothstep(0.5, 1.2, length((UV - vec2(0.5)) * vec2(aspect, 1.0)));
	col *= vig;

	COLOR = vec4(col * accent_intensity * brightness * appear, amount);
}
