extends Node2D

enum State {
    CENTERED,
    TRANSITION,
    FOLLOWING
}

var _state := State.CENTERED
var _target_pos := Vector2.ZERO
var _lerp_speed := 12.0

func _process(delta: float) -> void:
    # var p := Player.get_instance(self)
    # if _player_outside_center_bounds(p.global_position):
    #     if _state == State.CENTERED:
    #         _state = State.TRANSITION
    #         _target_pos = p.global_position
    #         _lerp_speed = 12.0
    #     if _state == State.TRANSITION:
    #         global_position = global_position.lerp(p.global_position, delta * _lerp_speed)
    #         if global_position.distance_to(_target_pos) < 2.0:
    #             _lerp_speed = 80.0
    #         if global_position.distance_to(p.global_position) < 2.0:
    #             _state = State.FOLLOWING
    #     if _state == State.FOLLOWING:
    #         global_position = p.global_position
    # else:
    #     if _state == State.FOLLOWING:
    #         _state = State.TRANSITION
    #     if _state == State.TRANSITION:
    #         global_position = global_position.lerp(Vector2.ZERO, delta * 8.0)
    #         if global_position.distance_to(Vector2.ZERO) < 2.0:
    #             _state = State.CENTERED
    #     if _state == State.CENTERED:
    #         global_position = Vector2.ZERO
    global_position = Player.get_instance(self).global_position

func _player_outside_center_bounds(p: Vector2) -> bool:
    return p.x < -128 or p.x > 128 or p.y < -128 or p.y > 128