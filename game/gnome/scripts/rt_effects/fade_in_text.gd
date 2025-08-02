@tool
class_name FadeInRTEffect
extends RichTextEffect

var bbcode = "fade_in"

var map: Dictionary[int, Vector2] = {}

func _process_custom_fx(fx: CharFXTransform) -> bool:
	var fade_time: float = fx.env.get("fade_time", 0.1)
	var current_fade_time := fx.range.x * fade_time
	var previous_fade_time := current_fade_time - fade_time
	var fade_t := clampf((fx.elapsed_time - previous_fade_time) / fade_time, 0.0, 1.0)
	fx.color = Color.TRANSPARENT.lerp(Color.WHITE, fade_t)

	var offset_dist: float = fx.env.get("offset_dist", 10.0)
	var offset_dir := Vector2.DOWN
	if fx.range.x in map:
		offset_dir = map[fx.range.x]
	else:
		offset_dir = _get_random_angle()
		map[fx.range.x] = offset_dir

	var offset_time: float = fx.env.get("offset_time", 0.1)
	var current_offset_time := fx.range.x * offset_time
	var preious_offset_time := current_offset_time - offset_time
	var offset_t := 1.0 - clampf((fx.elapsed_time - preious_offset_time) / offset_time, 0.0, 1.0)
	fx.offset = offset_dir * offset_dist * offset_t
	return true

func _get_random_angle() -> Vector2:
	var t := randf() * TAU
	return Vector2(cos(t), sin(t))