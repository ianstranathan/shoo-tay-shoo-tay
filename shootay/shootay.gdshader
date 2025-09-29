shader_type canvas_item;

uniform sampler2D noiseTexture: repeat_enable;
uniform float instance_time_seed;
uniform float noise_seed;
uniform vec4 src_col : source_color;

float grey_scale(vec3 _col){
	return (_col.x + _col.y + _col.z) / 3.0;
}
void fragment(){
	vec4 n_sample_1 = texture(noiseTexture, 0.3 * UV + 0.8 * vec2(0., (TIME + noise_seed)));
	vec4 n_sample_2 = texture(noiseTexture, 0.4 * UV + 0.6 * vec2(0., -1.2 * (TIME + noise_seed)));
	float mixed_r = (n_sample_1 * n_sample_2).r;
	vec4 sprite = texture( TEXTURE, UV +  0.1 * vec2(0, -0.05 + mixed_r + 0.05 *  sin(10. * TIME)));
	
	float param = grey_scale(sprite.xyz);
	vec3 col = mix(src_col.xyz, vec3(1.), param * param);
	COLOR = vec4(col, sprite.w * sprite.w);//vec4(src_col.xyz * grey_scale(sprite.xyz)), sprite.w * sprite.w * 0.8);
}
