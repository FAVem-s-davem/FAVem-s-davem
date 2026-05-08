shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 1.5;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	// Oprava poměru stran, aby kruh nebyl elipsa
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float dist = length(uv);
	float alpha = smoothstep(radius - 0.01, radius + 0.01, dist);
	// Při radius blízkém 0 vynutit úplnou černou — jinak středový pixel zůstane průhledný
	float open = step(0.005, radius);
	alpha = mix(1.0, alpha, open);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
