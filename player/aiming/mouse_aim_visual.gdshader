shader_type canvas_item;

void vertex() {
	VERTEX += vec2(sign(VERTEX.x), sign(VERTEX.y)) * 3. * sin(10. * TIME);
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

void fragment() {
	vec2 uv = 2. * UV - 1.;
	float mask = sdMoon(uv, -0.25 + 0.2 * UV.x * UV.x, 0.4, 0.4);
	mask = 1. - smoothstep(0.0, 0.25, mask);
	vec3 col = vec3(mask);
	COLOR = vec4(col, mask);
}

