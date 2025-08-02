extends Node

@export var text_box: TextBox
@export var r: DialogueRunner

func get_runner() -> DialogueRunner:
    return r

func _ready() -> void:
    text_box.hide()