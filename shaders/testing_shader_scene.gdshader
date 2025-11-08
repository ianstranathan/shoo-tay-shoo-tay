shader_type canvas_item;

uniform float tri_height = 0.5;

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

mat2 rot(float angle){
	return mat2( vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}


void fragment() {
	vec2 uv = 2. * UV - 1.;
	// -- shape sdf
	//uv = rot(PI / 2.0) * uv;
	//uv.x += sin(TIME);
   	//uv.x += (rot(TIME) * uv).x;
	float _sdf = sdTriangleIsosceles( uv + vec2(0., 0.6 * tri_height), vec2(0.35 * tri_height, tri_height));
	float shape_mask = (1. - smoothstep(0., 0.05, _sdf));
	COLOR = vec4(vec3(shape_mask), 1.);
}