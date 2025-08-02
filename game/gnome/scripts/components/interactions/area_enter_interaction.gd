class_name AreaEnterInteraction
extends InteractionComponent

@export var detect_bodies: bool = true
@export var detect_areas: bool = false

@export var player_only: bool = true
@export_flags_2d_physics var area_layers := 0
@export_flags_2d_physics var body_layers := 0

func _ready() -> void:
    collision_mask = collision_mask | body_layers | area_layers
    if player_only:
        collision_mask |= 4

    self.body_entered.connect(_body_entered)
    self.area_entered.connect(_area_entered)

func _body_entered(other: Node2D) -> void:
    if not detect_bodies:
        return
    var p := Player.get_instance(self)
    if player_only and other != p:
        return
    if other is PhysicsBody2D and other.collision_layer & body_layers == 0 and other != p:
        return
    if player_only:
        on_interacted.emit(Player.get_instance(self)._interactor)
    else:
        on_interacted.emit(null)

func _area_entered(other: Area2D) -> void:
    if not detect_areas:
        return
    if other.collision_layer & area_layers == 0:
        return
    if player_only:
        on_interacted.emit(Player.get_instance(self)._interactor)
    else:
        on_interacted.emit(null)