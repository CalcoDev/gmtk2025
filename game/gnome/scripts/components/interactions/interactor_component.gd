class_name InteractorComponent
extends RayCast2D

signal on_interacted(interaction: InteractionComponent)

func try_interact() -> bool:
    var coll := get_collider()
    if coll == null:
        return false
    var interaction := coll as InteractionComponent
    interaction.on_interacted.emit(self)
    return true

func can_interact() -> bool:
    return is_colliding()
