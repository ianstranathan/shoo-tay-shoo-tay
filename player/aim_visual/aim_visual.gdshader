shader_type canvas_item;

uniform float _scale: hint_range(0.0, 1.0, 0.1);
void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.x *= 3. * _scale;
}

float sdMoon(vec2 p, float d, float ra, float rb )
{
    p.y = abs(p.y);
    float a = (ra*ra - rb*rb + d*d)/(2.0*d);
    float b = sqrt(max(ra*ra-a*a,0.0));
    if( d*(p.x*b-p.y*a) > d*d*max(b-p.y,0.0) )
          return length(p-vec2(a,b));
    return max( (length(p          )-ra),
               -(length(p-vec2(d,0))-rb));
}

vec3 domain_repetition(vec3 p, vec3 S) {
    return mod(p, S) - 0.5 * S; // Centers the result around (0,0,0)
}

float mod1(float v, float m){
	return mod(v + m, 2. * m) - m;
}

void fragment() {
	vec2 uv = 2. * UV - 1.;
	uv.x *= 3.;
	vec2 p = uv + vec2(0.8, 0.);
	p.x = mod1(p.x, 0.8);
	float mask = sdMoon(p, -0.25 + 0.2 * UV.x * UV.x, 0.4, 0.4);
	float sm_mask = 1. - smoothstep(0., 0.1, mask);
	vec3 col = vec3(0., 1., 0.) + abs(sin(UV.x - 4. * TIME));
	col *= sm_mask;
	float _alpha = (0.5 * _scale + 0.1) * sm_mask * mix(1., 0.1, UV.x);
	COLOR = vec4(col, _alpha);
}
