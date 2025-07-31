class_name Rope
extends Node2D

class Point:
    var prev_pos := Vector2.ZERO
    var pos := Vector2.ZERO

    func _init(p_pos: Vector2 = Vector2.ZERO) -> void:
        prev_pos = p_pos
        pos = p_pos

@export var _line: Line2D
@export var _shape_cast: ShapeCast2D

@export var _point_count: int = 30
# @export var _segment_length: float = 2.0
@export var rope_length: float = 50.0

@export var _gravity: Vector2 = Vector2(0.0, 9.8)
@export var _damp_factor: float = 0.98

@export var _constraint_run_count: int = 50
@export var _collision_run_interval: int = 5

@export var _collision_radius: float = 1.0
@export var _bounce_factor: float = 0.1

# @export var _constr
var rope_start: Vector2

var _points: Array[Point] = []

var _point_distance: float = 0.0

func get_used_rope_distance() -> float:
    return _point_distance

func set_point(idx: int, pos: Vector2) -> void:
    _points[idx].pos = pos

func get_point(idx: int) -> Vector2:
    return _points[idx].pos

func get_point_count() -> int:
    return _point_count

func _ready() -> void:
    rope_start = global_position

    _points.resize(_point_count)
    for i in _point_count:
        _points[i] = Point.new(rope_start + Vector2.DOWN * (i * _get_segment_length()))

    _update_render()

func _process(_delta: float) -> void:
    _update_render()

func _physics_process(delta: float) -> void:
    _update_sim(delta)

func _get_segment_length() -> float:
    return rope_length / _point_count

func _update_sim(delta: float) -> void:
    _points[0].pos = rope_start
    _points[0].prev_pos = rope_start

    for i in _point_count:
        var point := _points[i]
        var vel := (point.pos - point.prev_pos) * _damp_factor

        point.prev_pos = point.pos
        point.pos += vel

        point.pos += _gravity * delta
    
    for ic in _constraint_run_count:
        var point_diff := _points[0].pos - _points[1].pos
        var diff := point_diff.length() - _get_segment_length()
        var change := point_diff.normalized() * diff
        _points[1].pos += change
        for i in _point_count - 2:
            point_diff = _points[i + 1].pos - _points[i + 2].pos
            diff = point_diff.length() - _get_segment_length()
            change = point_diff.normalized() * diff * 0.5
            _points[i + 1].pos -= change
            _points[i + 2].pos += change

        
        if ic % _collision_run_interval == 0:
            (_shape_cast.shape as CircleShape2D).radius = _collision_radius
            for point in _points:
                var vel := point.pos - point.prev_pos
                _shape_cast.global_position = point.pos
                _shape_cast.force_shapecast_update()
                for coll_info in _shape_cast.collision_result:
                    var closest_point: Vector2 = coll_info["point"]
                    var distance := point.pos.distance_to(closest_point)
                    if distance < _collision_radius:
                        var normal: Vector2 = coll_info["normal"]
                        # TODO(calco): Maybe handle case normal == Vector2.ZERO:
                        var depth := _collision_radius - distance
                        point.pos += normal * depth

                        var b := vel.bounce(normal) * _bounce_factor
                        # print(b)
                        vel = b
                point.prev_pos = point.pos - vel
    
    _point_distance = 0.0
    for i in _point_count-1:
        _point_distance += _points[i].pos.distance_to(_points[i+1].pos)

func _update_render() -> void:
    while _line.points.size() < _point_count:
        _line.add_point(Vector2.ZERO)
    while _line.points.size() > _point_count:
        _line.remove_point(_line.points.size() - 1)
    for i in _point_count:
        _line.points[i] = _points[i].pos