class_name RopeAttacher
extends Node2D

@export var attach_position: Node2D
@export var popup: Label

var _attached_ropes: Dictionary[CalcoRope, bool] = {}

func attach_rope(rope: CalcoRope) -> void:
    _attached_ropes[rope] = true
    rope.origin = attach_position.global_position
    # for i in 10:
    #     rope.(1.0 / 60.0)
    self.modulate = Color.GREEN

func detach_rope(rope: CalcoRope) -> void:
    _attached_ropes.erase(rope)
    if _attached_ropes.size() == 0:
        self.modulate = Color.RED

func _ready() -> void:
    self.modulate = Color.RED
    _hide_popup()

func _physics_process(_delta: float) -> void:
    for rope in _attached_ropes:
        rope.origin = attach_position.global_position

func _show_popup(rope_is_attached: bool) -> void:
    popup.visible = true
    popup.text = "Detach" if rope_is_attached else "Attach"

func _hide_popup() -> void:
    popup.visible = false