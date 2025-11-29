shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float sdRoundedX( in vec2 p, in float w, in float r )
{
    p = abs(p);
    return length(p-min(p.x+p.y,w)*0.5) - r;
}

void fragment() {
	vec2 uv = 2. * UV -1.;
	float d = sdRoundedX(uv, 0.5, 0.05);
	float mask = 1. - smoothstep(0., 0.02, d);
	COLOR = vec4(vec3(0.), mask);
}

