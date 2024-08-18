shader_type canvas_item;

uniform vec4 warm_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 gradient_direction = vec2(1.0, 0.0);                  // Gradient direction (normalized vector)
uniform float gradient_scale = 1.0;

uniform float normal_offset : hint_range(0, 10, .1) = 1.5;
uniform float time_influence : hint_range(0, 50) = 3;
uniform float y_div : hint_range(0, 10, .1) = 2.87;

void vertex() {
	VERTEX.x += sin(VERTEX.y * y_div + round(TIME * time_influence)) * normal_offset;
	VERTEX.y += sin(VERTEX.x * y_div + round(TIME * time_influence)) * normal_offset;
}

void fragment() {

	// Normalize the gradient direction
    vec2 dir = normalize(gradient_direction);
    
    // Get the position of the fragment relative to the object
    vec2 uv = UV - 0.5;
	
	// Project the UV coordinates onto the gradient direction
    float t = dot(uv, dir) * gradient_scale;
	
	// Clamp t to ensure it stays within the 0.0 to 1.0 range
    t = clamp(t, 0.0, 1.0);
	
	// Interpolate between the start and end colors based on the projection
    vec4 gradient_color = mix(COLOR, warm_color, t);
	gradient_color = vec4(gradient_color.rgb, COLOR.a);
	// Apply the color to the fragment
    COLOR = gradient_color;
}
