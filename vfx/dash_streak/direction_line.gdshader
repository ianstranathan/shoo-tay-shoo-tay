shader_type canvas_item;

//void vertex() {
	//VERTEX.x *= 2.;
//}

uniform sampler2D noise_tex: repeat_enable;
uniform float t: hint_range(0.0, 1.0, 0.1);

void fragment() {
	vec2 uv = 2. * UV - 1.;
	vec4 n_tex = texture(noise_tex, 2. * uv * vec2(0.15, 1.));
	float streak = smoothstep( 0.5, 0.55, n_tex.x);
	float half_line_thickness = -(0.1 * n_tex.x) * (uv.x - 1.) * (uv.x + 1.);
	float mask = 1. - smoothstep(half_line_thickness, half_line_thickness + 0.1, uv.y);
	mask *= 1. - smoothstep(-half_line_thickness, -half_line_thickness - 0.1, uv.y);
	COLOR = vec4(mask * streak);
	COLOR *= 1. - step(t, UV.x);
}