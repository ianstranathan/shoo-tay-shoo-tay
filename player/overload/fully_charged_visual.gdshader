shader_type canvas_item;


uniform float t: hint_range(0.0, 1.0, 0.1);

uniform sampler2D noise_tex: repeat_enable;
uniform vec4 src_col: source_color = vec4(vec3(0.), 1.);
void fragment() {
	vec2 uv = 2. * UV - 1.;
	float d = length(uv);
	vec2 polar =  vec2(d, atan(uv.y, uv.x));
	vec4 n_sample = texture(noise_tex, 0.3 * polar - 0.4 * TIME);

	float _step_threshold = mix(0.8, 0.3, t );
	float disp = step(_step_threshold, n_sample.x);
	float mask = 1. - smoothstep(0.9, 0.93, d + 0.7 * n_sample.x);
	mask *= disp;
	COLOR = vec4( src_col.xyz, mask * t);
}
