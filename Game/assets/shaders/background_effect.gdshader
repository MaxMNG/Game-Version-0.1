// Запасной фон «небула» (шаг 1, отложен): живой fbm-шум с реакцией на курсор.
// Все параметры приходят из NebulaConfig (resources/configs/nebula.tres) через
// скрипт background_effect.gd; значения по умолчанию — только fallback для превью.
// Ограничение GLSL ES (Compatibility): циклы только с константной границей,
// поэтому рабочее число октав — uniform, а граница цикла — константа.
shader_type canvas_item;

// Лимит октав — должен совпадать с MAX_OCTAVES в background_effect.gd.
const int MAX_OCTAVES = 5;

// Масштаб сдвига UV от возмущения курсора (форма эффекта; амплитуда — cursor_strength).
const float CURSOR_PUSH_SCALE = 0.1;

uniform vec4 background_color : source_color = vec4(0.02, 0.01, 0.05, 1.0);
uniform vec4 purple_color : source_color = vec4(0.23, 0.06, 0.42, 1.0);
uniform vec4 magenta_color : source_color = vec4(0.5, 0.12, 0.7, 1.0);
uniform vec4 green_color : source_color = vec4(0.05, 0.55, 0.3, 1.0);
// Общая сила цветовых слоёв поверх фона.
uniform float accent_intensity = 1.0;

uniform float noise_scale = 3.0;
uniform int octave_count = 4;
uniform float evolution_speed = 0.05;
uniform float warp_amount = 0.6;
// Расширение контраста шума (value noise по умолчанию даёт «туманный» диапазон).
uniform float noise_contrast = 2.2;
uniform vec2 green_anchor = vec2(0.78, 0.18);
uniform float green_radius = 0.3;

// Плотность цветовых слоёв и виньетки.
uniform float layer1_strength = 0.85;
uniform float layer2_strength = 0.7;
uniform float vignette_strength = 0.3;

// Возмущение от курсора; сила обновляется скриптом каждый кадр.
uniform vec2 cursor_uv = vec2(0.5, 0.5);
uniform float cursor_radius = 0.22;
uniform float cursor_strength = 0.0;
uniform float cursor_swirl = 0.55;

uniform float brightness = 1.0;
 // Отношение ширины к высоте вьюпорта; обновляется скриптом при изменении размера.
uniform float aspect = 1.7778;

// Маска проявления: эффект живёт в центре, к краям уходит в темноту.
// reveal_radius анимируется скриптом (появление из центра для интро).
uniform vec2 reveal_center = vec2(0.5, 0.5);
uniform float reveal_radius = 0.6;
uniform float reveal_softness = 0.5;

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
float contrast_expand(float n, float amount) {
	return clamp((n - 0.5) * amount + 0.5, 0.0, 1.0);
}

void fragment() {
	// Аспект-корректные координаты, чтобы облака не сплющивались по горизонтали.
	vec2 p = vec2(UV.x * aspect, UV.y);
	float t = TIME * evolution_speed;

	// Возмущение от курсора: гауссово затухание от радиуса + радиальный «пуш»
	// с завихрённостью (перпендикулярная компонента) — эффект «размазывания краски».
	vec2 cursor_pos = vec2(cursor_uv.x * aspect, cursor_uv.y);
	vec2 to_cursor = p - cursor_pos;
	float dist = length(to_cursor);
	float falloff = exp(-(dist * dist) / max(cursor_radius * cursor_radius, 0.0001));
	vec2 dir = vec2(0.0);
	if (dist > 0.00001) {
		dir = to_cursor / dist;
	}
	vec2 perp = vec2(-dir.y, dir.x);
	// Гасим возмущение в самом центре курсора: там направление не определено,
	// без этого на полной силе видна «звёздочка»-артефакт.
	float center_fade = smoothstep(0.0, cursor_radius * 0.35, dist);
	p += (dir + perp * cursor_swirl) * falloff * center_fade
			* cursor_strength * CURSOR_PUSH_SCALE;

	// Слой 1: крупный фиолетовый, медленный дрейф; warp-фаза тоже эволюционирует.
	vec2 q1 = p * noise_scale + vec2(t, -t * 0.7);
	float warp1 = fbm(q1 * 0.5 + vec2(11.0, 3.0) + vec2(t * 0.3, -t * 0.2), octave_count) - 0.5;
	float n1 = contrast_expand(fbm(q1 + warp1 * warp_amount * 2.0, octave_count), noise_contrast);

	// Слой 2: средний пурпурный/маджента, дрейф в другую сторону.
	vec2 q2 = p * noise_scale * 1.8 + vec2(-t * 1.3, t * 0.9) + vec2(31.0, 7.0);
	float warp2 = fbm(q2 * 0.5 + vec2(5.0, 19.0), octave_count) - 0.5;
	float n2 = contrast_expand(fbm(q2 + warp2 * warp_amount * 2.0, octave_count), noise_contrast);

	// Зелёное облако: гауссова маска вокруг якоря с рваным шумовым краем.
	vec2 green_pos = vec2(green_anchor.x * aspect, green_anchor.y);
	float green_dist = length(p - green_pos);
	float green_mask = exp(-(green_dist * green_dist) / max(green_radius * green_radius, 0.0001));
	float green_noise = contrast_expand(
			fbm(p * noise_scale * 1.4 + vec2(77.0, 13.0) + vec2(-t, t * 0.5), octave_count),
			noise_contrast);
	float green_amount = green_mask * smoothstep(0.4, 0.85, green_noise);

	// Сборка цвета: фон → фиолетовый слой → пурпурный → светлые «жилки» → зелёный.
	// Высокие нижние пороги держат большую часть экрана тёмной — облака «прожилки».
	vec3 col = background_color.rgb;
	col = mix(col, purple_color.rgb, pow(smoothstep(0.45, 0.9, n1), 1.5) * layer1_strength);
	col = mix(col, magenta_color.rgb, pow(smoothstep(0.55, 0.85, n2), 1.5) * layer2_strength);
	float highlight = pow(smoothstep(0.7, 0.95, n2), 2.0);
	col += magenta_color.rgb * highlight * 0.35;
	col = mix(col, green_color.rgb, green_amount);
	// Лёгкое свечение зелёного облака поверх фиолетового фона.
	col += green_color.rgb * green_amount * 0.25;

	// Виньетка: мягкое затемнение краёв (как на референсе).
	float vig = 1.0 - vignette_strength
			* smoothstep(0.5, 1.2, length((UV - vec2(0.5)) * vec2(aspect, 1.0)));
	col *= vig;

	// Маска проявления: гасим всё за пределами радиуса от центра.
	// Считаем от исходных UV (без курсорного сдвига), чтобы маска не дышала.
	// gate доводит маску до полного нуля при нулевом радиусе (иначе центр
	// остался бы видимым: smoothstep(r, r + s, 0) == 0 при любом r).
	vec2 reveal_pos = vec2(reveal_center.x * aspect, reveal_center.y);
	float reveal_dist = length(vec2(UV.x * aspect, UV.y) - reveal_pos);
	float reveal_gate = smoothstep(0.0, reveal_softness * 0.25, reveal_radius);
	float reveal_mask = (1.0 - smoothstep(
			reveal_radius, reveal_radius + reveal_softness, reveal_dist))
			* reveal_gate;
	col *= reveal_mask;

	COLOR = vec4(col * accent_intensity * brightness, 1.0);
}
