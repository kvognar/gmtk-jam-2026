//shader_type canvas_item;
//uniform vec4 masking_color : source_color;
//uniform float masking_range = 0.5;

shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 masking_color : source_color;
uniform float masking_range = 0.001;

//void vertex() {
//
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	vec4 world_pixel = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	if (length(abs(masking_color - world_pixel)) >= masking_range)
	{
		discard;
	}

	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
