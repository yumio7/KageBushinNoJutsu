shader_type canvas_item;
uniform float timer;
uniform float lifespan;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.a > 0.0) {
		COLOR.a = (lifespan-timer)/lifespan;
		COLOR.r = (timer)/lifespan;
		COLOR.g = 1.0;
		COLOR.b = 1.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
