extends SubViewport

@export var camera: Camera2D

func _process(delta: float) -> void:
    self.canvas_transform = camera.get_canvas_transform()
