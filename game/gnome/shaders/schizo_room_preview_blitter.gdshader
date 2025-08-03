shader_type canvas_item;

uniform sampler2D u_textures[16];
uniform int u_texture_count;

void fragment() {
    vec3 mask = texture(u_textures[0], UV).rgb;
    for (int i = 1; i < u_texture_count; ++i) {
        vec4 data = texture(u_textures[i], UV);
        if (data.g > 0.0) {
            mask = vec3(0.0, 1.0, 0.0);
        }
    }
    COLOR = vec4(mask, 1.0);
}