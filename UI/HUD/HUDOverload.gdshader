shader_type canvas_item;


float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

const vec3 reflect_col = vec3(1.0, 0.5, 0.25);
const vec3 transmit_col = vec3(0.4, 0.7, 1.0);
const float num_cols = 10.0;

uniform float t: hint_range(-2.0, 2.0, 0.33);
// -----------------------------
// NOTE: this is just making a grid of cells/squares; each square
// ----- is normalized [-1, 1] then hit with a box sdf
// ----- the rest of the shader is just overoperator + some modulation w/
// ----- the t uniform
void fragment() {
	float stretched_uv_x = num_cols * UV.x;
	// doing large domain dist on UV.y to make the boxs smaller
	// (looked too big with just 3 rows)
	float stretched_uv_y = 7.0 * UV.y;

	vec2 v = fract(vec2(stretched_uv_x, stretched_uv_x));
	// normalizing the cell values
	float squares = sdBox(2. * v - 1., vec2(0.5));
	float alpha = 1. - smoothstep(0.3, 0.4, squares);

	// normalized stretch uv
	vec2 uv = 2. * UV - 1.;
	// this is dividing the space in two, UV.x : [0, 10], num_cols/2. is 5 in  this case
	float r_t = step(t + num_cols/2., stretched_uv_x);
	float t_t = 1. - step(t + num_cols/2., stretched_uv_x);
	vec3 col = r_t * reflect_col * (1. - step(0., uv.x)) + t_t * transmit_col * step(0., uv.x);

	// add in some flash based on t, stepping with col.r to add to when col is black
	col += 0.2 * sin(mix(6., 20., abs(t) / 2.) * TIME) * step(0.1, col.r);

	// cutting of the columns and rows we don't want to show
	alpha *= step(5., stretched_uv_y) * (1. - step(6., stretched_uv_y));
	alpha *= step(3., stretched_uv_x) * (1. - step(7., stretched_uv_x));

	COLOR = vec4(col, alpha);
}

	// TODO Glow, maybe...
	//float dist = 1.0/squares;
    //dist *= 0.1;
    //dist = pow(dist, 0.8);
    //vec3 col = dist * reflect_col;
    //col = 1.0 - exp( -col );
