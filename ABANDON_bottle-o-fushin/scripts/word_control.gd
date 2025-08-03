@tool
class_name WordControl
extends Control

@export var text := "":
    set(value):
        text = value
        if is_node_ready():
            self.name = text
            (get_child(0) as RichTextLabel).text = text

func _ready() -> void:
    self.name = text
    (get_child(0) as RichTextLabel).text = text
    