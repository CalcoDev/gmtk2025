class_name RopeDynamicCollider
extends Node2D

@export var _rope: CalcoRope
@export var _shape: CollisionShape2D

var _rect: Rect2

func _physics_process(_delta: float) -> void:
    _rope.clear_spatial_hash_dyanmic()
    if _shape.shape is RectangleShape2D:
        var half_size: Vector2 = _shape.shape.size * 0.5
        var top_left := _shape.global_position - half_size
        var bottom_right := _shape.global_position + half_size
        _rect = Rect2(top_left - global_position, bottom_right - top_left)
        _rope.update_spatial_hash_dynamic(top_left, bottom_right, 0)
        queue_redraw()
    elif _shape.shape is CircleShape2D:
        pass
    elif _shape.shape is CapsuleShape2D:
        pass

func _draw() -> void:
    draw_rect(_rect, Color.RED, false, 2.0)