class_name RopeHandler
extends Node2D

@export var rope_attacher_area: Area2D

var _current_attach: RopeAttacher

func try_attach() -> bool:
    if _current_attach:
        return true
    return false

func _ready() -> void:
    rope_attacher_area.area_entered.connect(_on_rope_attacher_enter)
    rope_attacher_area.area_exited.connect(_on_rope_attacher_exit)

func _on_rope_attacher_enter(other: Area2D) -> void:
    var p := other.get_parent()
    if p is not RopeAttacher:
        return
    _current_attach = p

func _on_rope_attacher_exit(other: Area2D) -> void:
    var p := other.get_parent()
    if p == _current_attach:
        _current_attach = null