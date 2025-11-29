shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

void fragment() {
    // 1. Normalize fragment coordinates (from 0 to 1)
    vec2 uv = 2. * UV - 1.;
	float d = sdCircle(uv, 0.6);
	float mask = 1. - smoothstep(0., 0.01, d + 0.1 * cos(atan(uv.y, uv.x) * 10.));
	vec3 col = vec3(0.8);
	COLOR = vec4(col, mask);
}

