shader_type canvas_item;

uniform vec4 color : source_color;
uniform vec4 background_color : source_color;
uniform vec4 trajectory_color : source_color;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	
	if(c.a <= 0.0)
	{
		COLOR = background_color;
	}
	else if(c.a > 0. && c.a < 3./256.)
	{
		COLOR = trajectory_color;
	}
	else
	{
		COLOR = color;
	}
}
