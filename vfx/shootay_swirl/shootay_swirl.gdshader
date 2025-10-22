shader_type canvas_item;

render_mode unshaded;

uniform sampler2D noise_tex: repeat_enable;

uniform vec4 reflect_col = vec4(1., 0., 0., 1.);
uniform vec4 transmit_col = vec4(0., 0., 1., 1.);

//float plot(vec2 st, float pct){
  //return  smoothstep( pct-0.02, pct, st.y) -
          //smoothstep( pct, pct+0.02, st.y);
//}

float mod1(float v, float m){
	return mod(v + m, 2. * m) - m;
}

void fragment(){
	vec2 uv = 2. * UV - 1.;
	uv.y *= -1.0;
	uv.x *= -1.0;
    float a = atan(uv.y, uv.x) / PI; //[-1, 1]
	a = 0.5 * (a + 1.);

	float r = length(uv);
	//a += 0.5 * TIME;

	float a0 = mod(a + PI, 1);
	float r0 = r;
	a0 += 0.5 * TIME;
	a0 = mod(a0, 1.);
	float a1 = mod(a + 0.5 * TIME, 1.);
	float a2 = mod(3. * a, 1.);

	vec4 noise_sample = texture(noise_tex, vec2(r, a0));
	float noise_mask = smoothstep(noise_sample.r, noise_sample.r + 0.2, abs(sin(TIME)));


	// just playing around with the interpolant for the widths
	float mask1 = smoothstep(r0, r0 + 0.1, a0) *
    			 (1. - smoothstep( r0+ 0.1, r0 + 0.2, a0));
	float mask2 = smoothstep(r0, r0 + 0.1, a1) *
    			 (1. - smoothstep( r0+ 0.1, r0 + 0.2, a1));

	float total_mask = mask1 + mask2;
	noise_mask *= (1. - smoothstep(0.9, 0.95, r)) * (1. - total_mask);
	//total_mask *= 1. - noise_mask;
	COLOR = vec4(vec3(total_mask), total_mask + noise_mask);
}