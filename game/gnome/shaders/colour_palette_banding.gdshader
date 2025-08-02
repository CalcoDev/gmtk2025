shader_type canvas_item;

uniform sampler2D palette_texture : source_color;
uniform int palette_size = 16;

uniform sampler2D screen_tex: hint_screen_texture;

vec4 find_closest_color(vec4 color) {
    vec4 closest = texture(palette_texture, vec2(0.5 / float(palette_size), 0.5)).rgba;
    float min_dist = distance(color.rgb, closest.rgb);

    // Sample each pixel in the 1xN palette texture
    for(int i = 1; i < palette_size; i++) {
        float x = (float(i) + 0.5) / float(palette_size);
        vec4 palette_color = texture(palette_texture, vec2(x, 0.5)).rgba;
        float dist = distance(color.rgb, palette_color.rgb);
        if(dist < min_dist) {
            min_dist = dist;
            closest = palette_color;
        }
    }

    return closest;
}

void fragment() {
    vec4 screen_color = texture(screen_tex, SCREEN_UV);
    COLOR = find_closest_color(screen_color);
}