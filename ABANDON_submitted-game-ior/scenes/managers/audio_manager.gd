extends Node

static var d: Dictionary = {}

static func sound(sname: String) -> AudioStreamPlayer:
    return d[sname] as AudioStreamPlayer

static func sound_2d(sname: String) -> AudioStreamPlayer2D:
    return d[sname] as AudioStreamPlayer2D

func _ready() -> void:
    d.clear()
    for child in get_children():
        d[child.name] = child