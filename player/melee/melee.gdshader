shader_type canvas_item;


float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

//float ring( in vec2 p, in float r )
//{
	//return abs(sdCircle(p)) - r;
//}

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float rad: hint_range(0.0, 0.75, 0.1);
void fragment() {
	vec2 uv = 2. * UV - 1.;
	float mask = sdCircle(uv, rad);
	mask = abs(mask) - 0.2;
	mask = 1. - smoothstep(0., 0.05, mask);
	vec3 col = vec3(mask);
	COLOR = vec4(col, 0.5 * mask);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
