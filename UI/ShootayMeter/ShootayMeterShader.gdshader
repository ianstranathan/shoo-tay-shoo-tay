shader_type canvas_item;

void vertex(){
	VERTEX.y *= 0.5;
	VERTEX.y += 64.;
}
float mod1(float v, float m){
	return mod(v + m, 2. * m) - m;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

const vec3 reflect_col = vec3(1.0, 0.5, 0.25);
const vec3 transmit_col = vec3(0.4, 0.7, 1.0);

// TODO make it modular with the num shots, see 1/ 6
uniform float t: hint_range(-1.0, 1.0, 0.33);
//uniform int num_shots: hint_range(0, 6, 1);

void fragment() {
	vec2 uv = 2. * UV - 1.;

	// need to offset 0.25, 0.5, 0.75... 1. / [2,4,6]
	vec2 _uv = vec2(mod1(uv.x - 0.5, 1. / 6.), uv.y);
	float squares = sdBox(_uv, vec2((1. / 7.), 0.8));
	float mask = step(0.01, squares);
	float r_t = step(t, uv.x);
	float t_t = 1. - step(t, uv.x);
	vec3 _c =  (1. - mask) * ((1. - step(0., uv.x)) * r_t * reflect_col + step(0., uv.x) * t_t * transmit_col) * 
			   (1. + mix(0., 0.3, abs(t)) * sin( mix(0., 20., abs(t)) * TIME));
	COLOR = vec4( _c, _c.r);
}

