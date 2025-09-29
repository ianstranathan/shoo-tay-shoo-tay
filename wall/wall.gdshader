shader_type canvas_item;

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
const vec3 outline_col = vec3(1.0, 0.5, 0.25);
uniform float aspect_ratio = 2.;
//void fragment(){
	//vec2 uv = 2. * UV - 1.;
	//uv.x *= aspect_ratio;
	//float v = abs(sdBox(uv, vec2(1.5, 0.5))) - 0.1;
	//float dist = 1.0/v;
	//dist *= 0.25;
	//dist = pow(dist, 0.8);
	//vec3 col = dist * outline_col;
	//col = 1.0 - exp( -col );
	//COLOR = vec4(col, 1.) * dist;
//}

uniform vec2 dims;

void fragment(){
	vec2 uv = 2. * UV - 1.;
	uv.x *= dims.x / dims.y;
	float v = sdBox(uv, vec2(0.1, 0.1));
	v = pow(v, 0.8);
	vec3 col = v * outline_col ;//+  0.5 * sin(2. * TIME) * v * outline_col;
	COLOR = vec4(col, v);
}