shader_type canvas_item;

float sdTriangleIsosceles( in vec2 p, in vec2 q )
{
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  vec2( dot(b,b), s*(p.y-q.y)  ));
    return -sqrt(d.x)*sign(d.y);
}

const float tri_height = 0.5;
uniform float blur_length : hint_range(0.0, 1.0) = 0.15; // Length of the smear (downwards)
uniform int samples = 10;                                // Number of samples for smooth blending

float blur_mask(vec2 uv){
	// 2. Initialize Blending Variables
    float total_mask = 0.0;
    
    // Calculate the step size between samples along the blur_length
    float step_size = blur_length / float(samples - 1);
    
    // 3. Directional Sampling Loop
    // We sample the SDF at points above the current fragment (i.e., offset is positive on the Y-axis)
    // to smear the shape downwards (negative Y direction).
    for (int i = 0; i < samples; ++i) {
        
        // Calculate the offset for this sample, ranging from 0.0 to -blur_length
        // Start offset at the top of the smear (0.0) and step downwards (-Y).
        float offset = float(i) * step_size;
        
        // Calculate the position for this sample. 
        // We look UP the Y-axis to grab the shape and pull it down.
        vec2 sample_uv = uv - vec2(0.0, offset); 
        
        // Calculate the SDF at the offset position
        float _sdf = sdTriangleIsosceles( 
            sample_uv + vec2(0., 0.6 * tri_height), 
            vec2(0.35 * tri_height, tri_height)
        );

        // Convert the SDF to a crisp mask (0.005 is a thin feather)
        float sample_mask = (1. - smoothstep(0., 0.005, _sdf));
        
        // Accumulate the sampled mask
        // We multiply by a small inverse weight to taper the effect (optional but recommended)
        float sample_weight = 1.0 - (float(i) / float(samples)); // Taper mask to 0 at blur end
        total_mask += sample_mask * sample_weight;
    }
    // Normalize the total mask by the effective number of samples/weights
	return total_mask / float(samples);
}
void fragment() {
    vec2 uv = 2. * UV - 1.;
    float final_mask = blur_mask(uv);
    COLOR = vec4(vec3(final_mask), 1.);
}