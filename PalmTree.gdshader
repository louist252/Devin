shader_type canvas_item;

void vertex() {
	//if (VERTEX.y < 10.0)
	//	VERTEX += vec2((sin(TIME) * (10.0 / VERTEX.y)), 0);
	if (VERTEX.y < 3.0)
		VERTEX += vec2((sin(TIME) * (50.0 / VERTEX.y)), 0);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
