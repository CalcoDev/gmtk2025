extends Node2D

@export var play: Button
@export var quit: Button

@export var main_scene: PackedScene

func _ready() -> void:
    play.pressed.connect(func(): get_tree().change_scene_to_packed(main_scene))
    quit.pressed.connect(func(): get_tree().quit())
