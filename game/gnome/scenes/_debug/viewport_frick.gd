extends Camera2D

@export var cam: KCamera

func _process(_delta: float) -> void:
    global_position = cam.global_position
    global_rotation = cam.global_rotation
    offset = cam.offset