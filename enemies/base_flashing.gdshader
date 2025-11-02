shader_type canvas_item;

uniform float l; // the collision shape as a fraction of the sprite texture
uniform float t: hint_range(0.0, 7.0, 0.1);
uniform float exp_decay_modifier: hint_range(1.0, 7.0, 0.1);
uniform float health:  hint_range(0.0, 1.0, 0.1);
uniform vec4 src_color: source_color = vec4(1., 0., 1., 1.);

void vertex(){
	VERTEX += 20.0 * vec2(sign(VERTEX.x), sign(VERTEX.y)) * exp(-2. * t);
}
void fragment(){
	vec2 uv = 2. * UV - 1.;
	float d = 1. - smoothstep(l, l + 0.05, length(uv));


	vec3 col = mix(vec3(0.4 * src_color.xyz), src_color.xyz, health) + exp(-exp_decay_modifier * t);
	COLOR = vec4(col, d * d);
}