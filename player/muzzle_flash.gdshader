shader_type canvas_item;


uniform float t: hint_range(0.0, 1.0, 0.1);

uniform sampler2D noise_tex: repeat_enable;
uniform vec4 src_col: source_color = vec4(vec3(0.), 1.);
void fragment() {
	vec2 uv = 2. * UV - 1.;

	float d = length(uv);
	vec4 n_sample = texture(noise_tex, 0.3 * vec2(d, atan(uv.y, uv.x)));
	float disp = step(t, n_sample.x);
	float mask = 1. - smoothstep(0.9, 0.95, d + 0.7 * n_sample.x);
	mask *= disp;

	//vec3 col = src_col.xyz * mask;
	vec3 col = vec3(1.);
	COLOR = vec4( 1.2 * col, mask);
}
