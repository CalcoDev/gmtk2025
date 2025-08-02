class_name InteractionComponent
extends Area2D

signal on_interacted(interactor: InteractorComponent)

func try_interct(interactor: InteractorComponent) -> bool:
    on_interacted.emit(interactor)
    return true