extends Node2D

@export var quit: Button
@export var back: Button
@export var sfx_slider: Slider
@export var mus_slider: Slider

func _ready() -> void:
    quit.pressed.connect(func(): get_tree().quit())
    back.pressed.connect(func(): self.visible = false)
    self.visible = false

    var idx := AudioServer.get_bus_index("sfx")
    sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(idx))
    
    var midx := AudioServer.get_bus_index("music")
    mus_slider.value = db_to_linear(AudioServer.get_bus_volume_db(midx))

    sfx_slider.value_changed.connect(
        func(value: int):
            var aaaa := AudioServer.get_bus_index("sfx")
            AudioServer.set_bus_volume_db(aaaa, linear_to_db(value))
    )
    
    mus_slider.value_changed.connect(
        func(value: int):
            var aaaa := AudioServer.get_bus_index("music")
            AudioServer.set_bus_volume_db(aaaa, linear_to_db(value))
    )

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("esc"):
        self.visible = !self.visible
        if self.visible:

            var idx := AudioServer.get_bus_index("sfx")
            sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(idx))
            
            var midx := AudioServer.get_bus_index("music")
            mus_slider.value = db_to_linear(AudioServer.get_bus_volume_db(midx))
