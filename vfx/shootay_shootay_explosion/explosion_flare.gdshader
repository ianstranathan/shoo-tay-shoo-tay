shader_type canvas_item;

//render_mode blend_add;

uniform float alpha_controller: hint_range(0.0, 1.0, 0.1);

const float outer_ring_rad = 0.93;

void vertex(){
	VERTEX += 100.0 * vec2(sign(VERTEX.x), sign(VERTEX.y)) * (1. - alpha_controller);
}
void fragment()
{
	vec2 uv = 2. * UV - 1.;
	float dist =  length(uv);
	float l = (1. - smoothstep(outer_ring_rad, 1., dist)) *
			  (smoothstep(outer_ring_rad, outer_ring_rad + 0.05, dist));
	float core_mask = 1. / dist;
	core_mask *= 0.2;
	core_mask = pow(core_mask, 0.8);
	COLOR = vec4(vec3(core_mask), pow(core_mask, 3.0)) + vec4(l);
	COLOR.xyz *= 2.0;
	COLOR.a *= alpha_controller + l;
}