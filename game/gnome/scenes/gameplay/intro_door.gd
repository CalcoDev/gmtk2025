extends AreaEnterInteraction

var count := 0

func _ready() -> void:
    super._ready()
    on_interacted.connect(_interact)

func _interact(_i: InteractorComponent) -> void:
    count += 1
    if count == 1:
        var r := DialogueManager.get_runner()
        Player.get_instance(self).locked = true
        r.on_dia_complete.connect(_unfreeze_player)
        r.start_dialogue("intro_enter_hotel")
        r.add_command_handler("intro_scene_answer", _handle_scene_answer)

func _handle_scene_answer(cmd: DialogueCommand) -> void:
    if cmd.args[0] == "yes":
        print("entering hotel...")
    else:
        print("staying here...")

func _unfreeze_player() -> void:
    Player.get_instance(self).locked = false
    var r := DialogueManager.get_runner()
    r.on_dia_complete.disconnect(_unfreeze_player)
    r.remove_command_handler("intro_scene_answer", _handle_scene_answer)