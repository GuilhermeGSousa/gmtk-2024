shader_type canvas_item;

uniform sampler2D texture : source_color;
uniform vec2 uv_scale = vec2(2.0, 2.0);  // Controls how many times the texture repeats
uniform float blend_strength = 0.1;      // Controls the blending strength at the edges

void fragment() {
    // Get the UV coordinates and scale them for tiling
    vec2 uv = UV * uv_scale;
    
    // Wrap the UV coordinates using fract to repeat the texture
    vec2 wrapped_uv = fract(uv);
    
    // Compute the blending factor based on the distance to the nearest edge
    vec2 blend_uv = wrapped_uv * (1.0 - wrapped_uv);  // Gives a gradient from edges to center
    float blend_factor = min(blend_uv.x, blend_uv.y) * 4.0;  // Smoothstep-like effect

    // Adjust the blend factor using the blend_strength uniform
    blend_factor = pow(blend_factor, blend_strength);
    
    // Sample the texture at the wrapped UV coordinates
    vec4 color = texture(texture, wrapped_uv);
    
    // Blend the color towards the neighboring pixels
    vec2 offset = 1.0 / uv_scale;  // Offset to sample neighboring tiles
    vec4 blended_color = color;

    // Sample neighboring pixels and blend them
    blended_color += texture(texture, fract(wrapped_uv + vec2(offset.x, 0.0))) * blend_factor;
    blended_color += texture(texture, fract(wrapped_uv + vec2(-offset.x, 0.0))) * blend_factor;
    blended_color += texture(texture, fract(wrapped_uv + vec2(0.0, offset.y))) * blend_factor;
    blended_color += texture(texture, fract(wrapped_uv + vec2(0.0, -offset.y))) * blend_factor;

    // Normalize the blended color
    blended_color /= (1.0 + 4.0 * blend_factor);
    
    // Output the final color
    COLOR = blended_color;
}
