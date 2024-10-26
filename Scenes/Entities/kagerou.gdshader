shader_type canvas_item;
uniform float colourMultiplier = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	//if (!(COLOR.r >= 1.0 - EPSILON && COLOR.r <= 1.0 + EPSILON)) {
		//COLOR.r *= colourMultiplier;
		//COLOR.g *= colourMultiplier;
		//COLOR.b *= colourMultiplier;
	//}

	COLOR *= colourMultiplier;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
