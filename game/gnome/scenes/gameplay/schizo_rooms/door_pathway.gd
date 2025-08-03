@tool
class_name DoorPathway
extends Node2D

@export var id: String

@export var to: SchizoRoom
@export var to_id: String

var to_room: SchizoRoom:
    get():
        return to

# var a_glimpse_to_the_past_colours: ImageTexture
# var a_glimpse_to_the_past_lights: ImageTexture

# var color_rect: TextureRect
var light_rect: TextureRect
func _ready() -> void:
#     color_rect = TextureRect.new()
#     color_rect.visibility_layer = 1 + 8
    light_rect = TextureRect.new()
    add_child(light_rect)
    light_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
    light_rect.visibility_layer = 1 + 32
    light_rect.owner =  get_tree().edited_scene_root
    # get_parent().get_parent().preview_vp.add_child(light_rect)

# func _process(delta: float) -> void:
#     print(a_glimpse_to_the_past_lights == null)