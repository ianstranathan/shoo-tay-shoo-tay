shader_type canvas_item;

uniform float slider: hint_range(0.0, 1., 0.05);

uniform sampler2D noise_tex: repeat_enable;
void fragment() {
	vec4 noise_sample_1  = texture(noise_tex, 1.45 * UV - vec2(0.123, 0.2987) - 0.123 * vec2(0. ,TIME) );
	vec4 noise_sample_2  = texture(noise_tex, 1.21 * UV + vec2(0.275, 0.1937) + 0.083 * vec2(0. ,TIME));

	float nn = 2. * noise_sample_1.x * noise_sample_2.x;
	nn = 1. - mix(10., 2., slider) * nn;

    //
	float dist = 1. / nn;
	dist *= 0.2;
	dist = pow(dist, 0.8);
	vec3 charging_col = dist * vec3(1.0, 0.5, 0.25);
	charging_col = 1.0 - exp( -charging_col );
	charging_col += vec3(slider, 0., 0.) * abs(sin(10. * TIME));
	COLOR = vec4(charging_col, pow(dist, 4.));
	//COLOR = vec4(vec3(nn), 1.);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
