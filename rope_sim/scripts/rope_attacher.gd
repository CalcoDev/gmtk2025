class_name RopeAttacher
extends Node2D

@export var attach_position: Node2D
@export var popup: Label

var _attached_ropes: Dictionary[Rope, bool] = {}

func attach_rope(rope: Rope) -> void:
    _attached_ropes[rope] = true

func detach_rope(rope: Rope) -> void:
    _attached_ropes.erase(rope)

func _ready() -> void:
    _hide_popup()

func _physics_process(_delta: float) -> void:
    for rope in _attached_ropes:
        rope._rope_start = attach_position.global_position

func _show_popup(rope_is_attached: bool) -> void:
    popup.visible = true
    popup.text = "Detach" if rope_is_attached else "Attach"

func _hide_popup() -> void:
    popup.visible = false