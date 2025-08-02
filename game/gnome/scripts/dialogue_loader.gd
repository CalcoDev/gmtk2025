extends Node

@export_file("*.txt") var files: Array[String] = []
@export var runner: DialogueRunner

func _ready() -> void:
    var r := runner if runner != null else DialogueManager.get_runner()
    for file in files:
        r.prepare_dialogue(file)

func _exit_tree() -> void:
    var r := runner if runner != null else DialogueManager.get_runner()
    for file in files:
        r.unprepare_undialogue(file)