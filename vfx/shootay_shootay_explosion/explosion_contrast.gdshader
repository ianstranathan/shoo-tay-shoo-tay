shader_type canvas_item;

uniform float alpha_controller: hint_range(0.0, 1.0, 0.1);

void vertex(){
	VERTEX *= 2.0;
}
void fragment() {
	vec4 tex_sample = texture(TEXTURE, UV);
	float first_mask = 1. - smoothstep(0.5, .55, tex_sample.r);
	vec3 flare_col =  vec3(tex_sample.a) * first_mask;
	flare_col += pow(2. * length(2. * UV - 1.), 2.) * first_mask;
	COLOR = 2. * vec4(flare_col, tex_sample.a * alpha_controller);
}