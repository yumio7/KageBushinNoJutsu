shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int grayscaleHorizontal = 0; // can be -1, [any], or 1 (grayscale left, none, and right)
uniform vec2 coordApply;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	float avg = COLOR.r + COLOR.g + COLOR.b / 3.0;
	if (grayscaleHorizontal == 1) {
		COLOR.rgb = UV.x >= 0.5 ? vec3(0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b) : COLOR.rgb;
	} else if (grayscaleHorizontal == -1) {
		COLOR.rgb = UV.x <= 0.5 ? vec3(0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b) : COLOR.rgb;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
