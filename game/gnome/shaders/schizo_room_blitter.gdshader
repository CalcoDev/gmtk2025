shader_type canvas_item;

uniform sampler2D u_tex: filter_nearest;
uniform sampler2D u_mask_tex: filter_nearest;
uniform sampler2D u_mask_mask_tex: filter_nearest;

void fragment() {
	vec3 color = texture(u_tex, UV).rgb;
    float mask = texture(u_mask_tex, UV).g;
    float maskmask = float(texture(u_mask_mask_tex, UV).r > 0.0);
    float f = float(mask + maskmask > 0.0);
    COLOR = vec4(mix(vec3(0.0), color, f), 1.0);
}