class_name RopeHandler
extends Node2D

@export var rope: Rope

@export var rope_attacher_area: Area2D

var _current_attach: RopeAttacher
var _awaiting_attach: bool = false
var _is_attached: bool = false

func try_attach() -> bool:
    if _current_attach and _awaiting_attach:
        if _is_attached:
            _current_attach.detach_rope(rope)
            _is_attached = false
        else:
            _current_attach.attach_rope(rope)
            _is_attached = true
        _awaiting_attach = false
        return true
    return false

func get_attached_point() -> RopeAttacher:
    return _current_attach

func is_attached() -> bool:
    return _is_attached

func get_rope() -> Rope:
    return rope

func _ready() -> void:
    rope_attacher_area.area_entered.connect(_on_rope_attacher_enter)
    rope_attacher_area.area_exited.connect(_on_rope_attacher_exit)

func _physics_process(_delta: float) -> void:
    rope.rope_start = get_parent().global_position

func _on_rope_attacher_enter(other: Area2D) -> void:
    var p := other.get_parent()
    if p is not RopeAttacher:
        return
    if _is_attached and _current_attach != p:
        return
    _current_attach = p
    _awaiting_attach = true
    _current_attach._show_popup(_is_attached)

func _on_rope_attacher_exit(other: Area2D) -> void:
    var p := other.get_parent()
    if p == _current_attach:
        _current_attach._hide_popup()
        if not _is_attached:
            _current_attach = null