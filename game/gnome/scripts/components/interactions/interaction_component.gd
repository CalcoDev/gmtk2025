class_name InteractionComponent
extends Area2D

func _notification(what: int) -> void:
    if what == NOTIFICATION_ENTER_TREE:
        collision_mask |= 256

signal on_interacted(interactor: InteractorComponent)

func try_interct(interactor: InteractorComponent) -> bool:
    on_interacted.emit(interactor)
    return true