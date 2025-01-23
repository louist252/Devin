shader_type canvas_item;

void vertex() {
	VERTEX += vec2(0, cos(TIME) * 0.3);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
