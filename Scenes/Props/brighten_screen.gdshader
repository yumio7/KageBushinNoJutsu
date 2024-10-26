shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float colourAdd = 0.0;
uniform float multiplier = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb += colourAdd;
	COLOR.rgb *= multiplier;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
