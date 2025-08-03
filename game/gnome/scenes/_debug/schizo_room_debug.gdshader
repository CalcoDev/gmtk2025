shader_type canvas_item;

void fragment() {
	vec4 data = texture(TEXTURE, UV);
    COLOR = vec4(0.0, float(data.g > 0.0), 0.0, float(data.g > 0.0));
}