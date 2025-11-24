shader_type canvas_item;

void vertex() {
	VERTEX.x *= 2.;
}

uniform sampler2D noise_tex: repeat_enable;
void fragment() {
	vec2 uv = 2. * UV - 1.;
	float streak = smoothstep( 0.5, 0.55, texture(noise_tex, UV * vec2(0.1, 1.)).x);
	float half_line_thickness = -0.5 * (uv.x - 1.) * (uv.x + 1.);
	float mask = 1. - smoothstep(half_line_thickness, half_line_thickness + 0.01, uv.y);
	mask *= 1. - smoothstep(-half_line_thickness, -half_line_thickness - 0.01, uv.y);
	COLOR = vec4(vec3(1.), 1.);//vec4(mask * streak);
}
