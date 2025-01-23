shader_type canvas_item;

uniform vec4 color : source_color;
uniform vec2 speed = vec2(0.03, 0.07);

uniform sampler2D origNoise : repeat_enable;
uniform sampler2D content : hint_screen_texture;

uniform float wave_strength = 15;

void fragment() {
	vec2 uv = UV + speed * TIME;
	vec2 noise = texture(origNoise, uv).rg;

	COLOR = vec4(color.r, color.g, color.b, 1) + vec4(noise.x, noise.y, 1, 1);
	COLOR *= texture(content, SCREEN_UV + noise * (wave_strength / 100.0));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
