shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
float sdTriangleIsosceles( in vec2 p, in vec2 q )
{
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  vec2( dot(b,b), s*(p.y-q.y)  ));
    return -sqrt(d.x)*sign(d.y);
}

const float tri_height = 0.9;
uniform float t: hint_range(0.0, 1.0, 0.05);
uniform vec4 src_col: source_color = vec4(0.4, 0.6, 0.8, 1.);
uniform sampler2D cracked_tex: repeat_enable;


const vec3 charging_col_src = vec3(1.0, 0.5, 0.25);

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}

uniform float dmg_scale: hint_range(0.0, 1.0, 0.25);
void fragment() {
	vec2 uv = 2. * UV - 1.;
	
	vec4 cracked_src = texture(cracked_tex, 3. * dmg_scale * (UV - vec2(0.5)) + vec2(0.5));
	
	// --
	uv = rot(PI / 2.0) * uv;
	float _sdf = sdTriangleIsosceles( uv + vec2(0., 0.6 * tri_height), vec2(0.35 * tri_height, tri_height));
	float shape_mask = (1. - smoothstep(0., 0.05, _sdf));
	
	
	// -------------- glow
	float dist = 1. / clamp(_sdf, 0.001, 1.);//mask = smoothstep(0.01, 0.04, mask);
	float charging_alpha = pow((1. - _sdf), 4.0);
	dist *= 0.1;
	dist = pow(dist, 0.8);
	vec3 charging_col = dist * vec3(1.0, 0.5, 0.25);
	
	charging_col = 1.0 - exp( -charging_col );

	vec4 col = mix(vec4(charging_col, shape_mask), vec4(charging_col, charging_alpha), t);
	
	
	// Cracked glowing stuff
	float cracked_glow_dist = 1. / ((1. - cracked_src.x) + (0.2 * (sin( mix(2., 20., dmg_scale * dmg_scale)
	* TIME))));
	cracked_glow_dist *= 0.1;
	cracked_glow_dist = pow(cracked_glow_dist, 0.8);
	vec3 cracked_col = cracked_glow_dist * charging_col_src;
	cracked_col = 1.0 - exp( -cracked_col );
	
	// 
	
	float v = (1. - dmg_scale + 0.2); // col changing with dmg
	vec4 cracked_out_col = (v * src_col * (1. - cracked_src.x)) + 2. * step(0.1, dmg_scale) * vec4(cracked_col, cracked_src.x);
	
	//col.w -= cracked_out_col.w;
	//col += cracked_out_col;
	//COLOR = cracked_out_col;
	vec4 c = mix(src_col, cracked_out_col, dmg_scale) * shape_mask;
	COLOR = mix(c, vec4(charging_col, charging_alpha), t);
	//COLOR = cracked_out_col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
