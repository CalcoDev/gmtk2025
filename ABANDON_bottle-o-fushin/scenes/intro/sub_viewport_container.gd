extends SubViewportContainer

func _ready() -> void:
    var vp := get_child(0) as SubViewport
    print(get_viewport().get_visible_rect().size)
    self.stretch_shrink = round(self.get_viewport_rect().size.x / vp.size.x)