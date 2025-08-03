extends Node2D

@export var colors_vp: SubViewport
@export var light_vp: SubViewport
@export var lights_2_vp: SubViewport
@export var room_vp: SubViewport

func _ready() -> void:
    light_vp.world_2d = colors_vp.world_2d
    lights_2_vp.world_2d = colors_vp.world_2d
    room_vp.world_2d = colors_vp.world_2d