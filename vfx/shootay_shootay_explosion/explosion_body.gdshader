shader_type canvas_item;


float EaseInSine(float x)
{
    return 1.0 - cos((x * PI) / 2.0);
}

vec2 rot_at(vec2 uv, float angle, vec2 at){
	vec2 ret = uv;
	ret -= at;
	ret = mat2( vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle)) ) * uv;
	return (ret + at);
}

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

uniform sampler2D noise_tex: repeat_enable;
uniform sampler2D gradient_tex;
uniform float alpha_controller: hint_range(0.0, 1.0, 0.1);
uniform float seed;
const float dissolve_duration = 1.;

void fragment(){
	//float alpha_controller = mod(TIME, dissolve_duration) / dissolve_duration; // [0, 1];
	//float alpha_controller = _time;
	vec2 uv = 2. * UV - 1.;

	// +++
	// uv *= 0.5;
	// +++
	float _rnd = random( vec2( seed ));
	vec4 noise_tex_sample = texture(noise_tex, rot_at(UV - vec2(_rnd), _rnd, vec2(0.5)));
	float a = smoothstep(alpha_controller, alpha_controller + 0.025, 2. * noise_tex_sample.r);
	//a = EaseInExpo(a);
	// float abs_normalized_angle = atan(abs(uv.y), abs(uv.x)) / (3.14 /2.);
	float rad = max(1.5, 1.5 * _rnd) * noise_tex_sample.r;// +
	            //0.1 * noise_tex_sample.r * cos(10. * (noise_tex_sample.r * abs_normalized_angle) - 2. * TIME);
	rad = mix(rad / 4.0, rad, EaseInSine(alpha_controller));
	rad = clamp(rad, 0., 1.);
	float circle_mask = 1. - smoothstep(rad, rad + 0.01, length(uv));
	// how many cols: 4
	// step size = 1/ how many cols
	float step_col = (0.10) * floor(10. * rad);
	vec3 smoke_col = texture(gradient_tex, vec2(step_col)).xyz;
	vec3 col = smoke_col * circle_mask * a;

	COLOR = vec4(col, circle_mask * a * (1. - step(1., alpha_controller)));
}
