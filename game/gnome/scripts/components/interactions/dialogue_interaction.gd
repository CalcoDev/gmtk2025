class_name DialogueInteraction
extends InteractionComponent

@export var dialogue_id: String

func _ready() -> void:
    self.on_interacted.connect(_on_interacted)

func _on_interacted(_interactor: InteractorComponent) -> void:
    var r := DialogueManager.get_runner()
    Player.get_instance(self).locked = true
    r.on_dia_complete.connect(_unfreeze_player)
    r.start_dialogue(dialogue_id)

func _unfreeze_player() -> void:
    Player.get_instance(self).locked = false
    DialogueManager.get_runner().on_dia_complete.disconnect(_unfreeze_player)