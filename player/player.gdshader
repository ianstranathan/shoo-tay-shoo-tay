shader_type canvas_item;

uniform float dmg_scale: hint_range(0.0, 1.0, 0.25);
uniform float t: hint_range(0.0, 1.0, 0.05);
uniform float boost_time: hint_range(0.0, 1.0, 0.05);
uniform float hit_time:hint_range(0.0, 4.0, 0.05) = 4.0;


void vertex() {
	float anim_t = 10. * t;
	//float s = mix(1., 4., dmg_scale) * (sin( mix(4., 12., dmg_scale * dmg_scale) * anim_t));
	float m = mix(1., 7., t) * (sin( mix(4., 12., t * t) * anim_t));
	VERTEX += vec2(sign(VERTEX.x), sign(VERTEX.y)) * m;// (s + m) ;
	
	// getting hit
	VERTEX += 20.0 * vec2(sign(VERTEX.x), sign(VERTEX.y)) * exp(-3. * hit_time);
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

const float tri_height = 0.5;
uniform vec4 src_col: source_color = vec4(1.0, 0.6, 0., 1.);
uniform sampler2D cracked_tex: repeat_enable;



const vec3 charging_col_src = vec3(1.0, 0.5, 0.25);

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}


void fragment() {
	vec2 uv = 2. * UV - 1.;
	// -- shape sdf
	uv = rot(PI / 2.0) * uv;
   
	float _sdf = sdTriangleIsosceles( uv + vec2(0., 0.6 * tri_height), vec2(0.35 * tri_height, tri_height));
	float shape_mask = (1. - smoothstep(0., 0.05, _sdf));
	
	//float _sdf = shape_mask;
	// -------------- overcharge glow
	float dist = 1. / clamp(_sdf, 0.001, 1.);//mask = smoothstep(0.01, 0.04, mask);
	float charging_alpha = pow((1. - _sdf), 3.0);
	dist *= 0.1;
	dist = pow(dist, 0.8);
	vec3 charging_col = dist * vec3(1.0, 0.5, 0.25);

	charging_col = 1.0 - exp( -charging_col );


	// Cracked glowing stuff
	// scaling numbers are arbitrary, just playing around to see what looks ok
	vec4 cracked_src = texture(cracked_tex, 4. * dmg_scale * (UV - vec2(0.5)) + vec2(0.5));

	// 0.5 * (sin(x) + 1)
	// float cracked_glow_variation = 0.5 * (0.5 * (sin(mix(4., 12., dmg_scale * dmg_scale) * TIME) + 1.0))
	//float cracked_glow_dist = 1. / ((1. - cracked_src.x) + (0.5 * (abs(sin( mix(4., 12., dmg_scale * dmg_scale) * TIME)))));
	float cracked_glow_dist = 1. / ((1. - cracked_src.x) + (0.8 * (0.5 * (sin(mix(4., 12., dmg_scale * dmg_scale) * 10. * t) + 1.0))));
	cracked_glow_dist *= 0.1;
	cracked_glow_dist = pow(cracked_glow_dist, 0.8);
	vec3 cracked_col = cracked_glow_dist * charging_col_src;
	cracked_col = 1.0 - exp( -cracked_col );

	//
	float shifted_dmg_scale = dmg_scale + 0.3;
	float cracked_alpha = ((1. - shifted_dmg_scale) + 0.5) * (1. - 0.2 * cracked_src.x) + 3. * cracked_src.x;
	//
	float _a = mix(0., 0.1 * cracked_alpha * cracked_alpha, shifted_dmg_scale);
	vec4 c = vec4(src_col.xyz + _a, cracked_alpha) * shape_mask;//mix(src_col, vec4(src_col.xyz, cracked_alpha), 1.) * shape_mask;
	c *= smoothstep(0.2, 1.8, c.w);

	// this is just trying to play with the time curve on the mixing
	float _t = smoothstep(0., 1., t);
	
	COLOR = c + vec4(mix(vec3(0.), charging_col, t), mix(c.w, charging_alpha * charging_alpha, _t));
	
	COLOR.xyz += exp(-3.0 * hit_time) * shape_mask;
}
