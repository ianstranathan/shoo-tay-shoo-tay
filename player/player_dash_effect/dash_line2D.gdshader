shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform sampler2D noise_tex: repeat_enable;
void fragment() {
	vec2 uv = 2. * UV - 1.;
	vec4 n_tex = texture(noise_tex, UV * vec2(0.5, 1.));
	float streak = smoothstep( 0.5, 0.55, n_tex.x);
	float half_line_thickness = -0.5 * (uv.x - 1.) * (uv.x + 1.);
	float mask = 1. - smoothstep(half_line_thickness, half_line_thickness + 0.1, uv.y);
	mask *= 1. - smoothstep(-half_line_thickness, -half_line_thickness - 0.1, uv.y);
	COLOR = vec4(mask * streak);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
