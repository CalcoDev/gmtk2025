class_name RopeDynamicCollider
extends Node2D

@export var _rope: CalcoRope
@export var _shape: CollisionShape2D

func _physics_process(_delta: float) -> void:
    _rope.clear_spatial_hash_dyanmic()
    if _shape.shape is RectangleShape2D:
        _rope.update_spatial_hash_dynamic_obb(_shape.global_position, _shape.shape.size * 0.5, _shape.global_rotation)
    elif _shape.shape is CircleShape2D:
        _rope.update_spatial_hash_dynamic_circle(_shape.global_position, _shape.shape.radius)
    elif _shape.shape is CapsuleShape2D:
        pass