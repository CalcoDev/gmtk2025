shader_type canvas_item;

bool raymarch(vec2 origin, vec2 dir, vec2 target, out vec2 hit_pos) {
	float current_dist = 0.0;

	vec2 og_sign = normalize(target - origin);

	for (int i = 0; i < 100; i++) {
		vec2 sample_point = origin + (dir * current_dist);

		if (sample_point.x >= 1.0 || sample_point.x <= 0.0 || sample_point.y >= 1.0 || sample_point.y <= 0.0) {
			return false;
		}

		vec2 curr_sign = normalize(sample_point - target);
		if ( distance(og_sign, curr_sign) < 0.01 ) {
			return false;
		}

		//float dist_to_surface = texture(u_distance_field_tex, sample_point).r;
        float dist_to_surface = texture_sdf(screen_uv_to_sdf(sample_point));

		if (dist_to_surface < 0.005f) {
			hit_pos = sample_point;
			return true;
		}

		current_dist += dist_to_surface;
	}

	return false;
}

void fragment() {
    COLOR = vec4(0.0, 0.0, 0.0, 1.0) * COLOR;
}

void light() {
    ////float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
    ////LIGHT = vec4(vec3(LIGHT_ENERGY), LIGHT_COLOR.a);
    LIGHT = vec4(vec3(0.0, 1.0, 0.0), 1.0);
}
