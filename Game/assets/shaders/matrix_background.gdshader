// Фон «Матрица» (этап 2 работы над фоном, 2-я итерация): статичная сетка
// настоящих глифов из атласа (Tools/bake_matrix_atlas.py: 94 символа).
// Никаких падающих потоков: глифы светятся только вокруг движущегося курсора.
// Яркость ячейки = маска глифа × заметный радиальный градиент × заряд движения
// (в покое заряд держится на минимальном полу — слабое свечение под курсором).
// Плюс статичное цветовое свечение в центре (не зависит от курсора и глифов).
// Все параметры приходят из MatrixConfig через скрипт matrix_background.gd;
// значения по умолчанию — только fallback для превью.
shader_type canvas_item;

// Число точек шлейфа — должно совпадать с TRAIL_POINTS в matrix_background.gd.
const int TRAIL_POINTS = 24;
// Атлас глифов: 94 символа, сетка 16x6 (см. Tools/bake_matrix_atlas.py).
const int GLYPH_COLS = 16;
const int GLYPH_ROWS = 6;
const int GLYPH_COUNT = 94;

uniform sampler2D glyph_atlas : filter_linear, repeat_disable;

uniform float cell_size_px = 16.0;

uniform float glow_radius = 0.18;
uniform float glow_softness = 2.0;
uniform float charge_boost = 1.0;

uniform vec2 trail_points[TRAIL_POINTS];
uniform float trail_age[TRAIL_POINTS];
// Сглаженная позиция курсора (центр подсветки) в UV.
uniform vec2 cursor_uv = vec2(0.5, 0.5);
// Нормированный заряд движения 0..1: 0 в покое, 1 на быстром движении.
uniform float charge_strength = 0.0;
uniform float charge_decay_rate = 1.6;

uniform vec4 color_glow : source_color = vec4(0.6, 0.95, 1.0, 1.0);
uniform vec4 color_halo : source_color = vec4(0.2, 0.5, 0.9, 1.0);
uniform vec4 background_color : source_color = vec4(0.01, 0.02, 0.05, 1.0);
uniform vec4 color_center : source_color = vec4(0.15, 0.35, 0.7, 1.0);

// Статичное центральное свечение: не зависит от курсора и заряда.
uniform float center_glow_strength = 0.15;
uniform float center_glow_radius = 0.35;
// Минимальный заряд: подсветка под курсором не гаснет ниже этой доли.
uniform float charge_floor = 0.1;

uniform float brightness = 0.9;
// Появление из темноты: 0 — чёрный экран, 1 — полностью видно.
uniform float appear = 1.0;
// Размер вьюпорта в пикселях; обновляется скриптом при изменении размера.
uniform vec2 view_size = vec2(1920.0, 1080.0);

// Хэш 2D (алгоритм Dave Hoskins) — стабильный индекс глифа для ячейки.
float hash21(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	// Статичная сетка ячеек в пикселях: стабильна при любом разрешении.
	vec2 grid = UV * view_size / max(cell_size_px, 1.0);
	vec2 cell = floor(grid);
	vec2 cell_fract = fract(grid);

	// Настоящий глиф из атласа: индекс — хэш ячейки, выборка с полями
	// от краёв ячейки, чтобы глифы соседних ячеек не кровоточили.
	int glyph_idx = int(hash21(cell) * float(GLYPH_COUNT));
	vec2 glyph_cell = vec2(float(glyph_idx % GLYPH_COLS), float(glyph_idx / GLYPH_COLS));
	vec2 atlas_uv = (glyph_cell + mix(vec2(0.08), vec2(0.92), cell_fract))
			/ vec2(float(GLYPH_COLS), float(GLYPH_ROWS));
	float mask = texture(glyph_atlas, atlas_uv).r;

	// Заметный радиальный градиент: 1 вплотную к курсору → 0 на радиусе.
	float aspect = view_size.x / max(view_size.y, 1.0);
	vec2 cursor = vec2(cursor_uv.x * aspect, cursor_uv.y);
	vec2 p = vec2(UV.x * aspect, UV.y);
	float dist = length(p - cursor);
	float glow = pow(clamp(1.0 - dist / max(glow_radius, 0.0001), 0.0, 1.0),
			max(glow_softness, 0.01));

	// Шлейф: свежие точки хвоста продлевают подсветку по траектории.
	float trail_glow = 0.0;
	for (int i = 0; i < TRAIL_POINTS; i++) {
		vec2 tp = vec2(trail_points[i].x * aspect, trail_points[i].y);
		float d = length(p - tp);
		float fade = exp(-trail_age[i] * charge_decay_rate);
		trail_glow = max(trail_glow,
				pow(clamp(1.0 - d / max(glow_radius, 0.0001), 0.0, 1.0),
				max(glow_softness, 0.01)) * fade);
	}
	glow = max(glow, trail_glow * 0.7);

	// Широкий слабый ореол вокруг курсора (без маски глифа).
	float halo = exp(-pow(dist / max(glow_radius * 2.5, 0.0001), 2.0));

	// В покое заряд гаснет до минимального пола — символы под курсором
	// сохраняют слабое свечение и никогда не падают в полный ноль.
	float charge = max(clamp(charge_strength, 0.0, 1.0), charge_floor) * charge_boost;
	vec3 col = background_color.rgb;
	col += color_glow.rgb * mask * glow * charge;
	col += color_halo.rgb * halo * charge * 0.35;

	// Статичное свечение в центре: постоянный виньеточный эффект,
	// не зависит от курсора и не влияет на яркость глифов.
	vec2 center_uv = vec2(0.5 * aspect, 0.5);
	float center_dist = length(p - center_uv);
	float center_glow = exp(-pow(center_dist / max(center_glow_radius, 0.0001), 2.0));
	col += color_center.rgb * center_glow * center_glow_strength;

	COLOR = vec4(col * brightness * appear, 1.0);
}
