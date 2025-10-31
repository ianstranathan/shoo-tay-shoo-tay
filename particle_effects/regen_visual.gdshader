shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float mask = smoothstep(0., 1., COLOR.x);
	COLOR = vec4(0.7 * vec3(1., 0., 0.) * mask + 0.1 * sin(TIME), mask);
}
