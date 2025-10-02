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

uniform float is_flashing = 0.0;

void fragment() {
	vec2 uv = 2. * UV - 1.;
	float _sdf = sdTriangleIsosceles( uv + vec2(0., 0.6 * tri_height), vec2(0.35 * tri_height, tri_height));

	// -------------- regular col
	float flashing_switch =  step(0.1, is_flashing);
	float shape_mask = (1. - smoothstep(0., 0.05, _sdf));
	vec4 reg_col = shape_mask * ( (vec4(0.2, 0.3, 0.8, 1.) * (1. - flashing_switch) +
								  (vec4(1., 0., 0., 1.) * flashing_switch) ));

	reg_col += flashing_switch * vec4(1., 0., 0, 0.) * sin( 30. * TIME);
	// -------------- glow
	float dist = 1. / clamp(_sdf, 0.001, 1.);//mask = smoothstep(0.01, 0.04, mask);
	float charging_alpha = pow((1. - _sdf), 4.0);
	dist *= 0.1;
	dist = pow(dist, 0.8);
	vec3 charging_col = dist * vec3(1.0, 0.5, 0.25);
	charging_col = 1.0 - exp( -charging_col );

	vec4 col = mix(reg_col, vec4(charging_col, charging_alpha), t);
	COLOR = col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
