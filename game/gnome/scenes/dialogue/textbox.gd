class_name TextBox
extends Control

@export var title_lbl: RichTextLabel
@export var text_lbl: RichTextLabel

@export var speaker_outline: TextureRect
@export var speaker_icon: TextureRect

@export var title_line: Control
# @export var title_spacer: Control

@export var options_container: Control

var enabled := true

func box_show() -> void:
    enabled = true
    visible = true

func box_hide() -> void:
    enabled = false
    visible = false

func toggle_lineview(en: bool) -> void:
    text_lbl.visible = en

func toggle_optionview(en: bool) -> void:
    options_container.visible = en

func toggle_speaker(en: bool) -> void:
    speaker_outline.visible = en

func toggle_title(en: bool) -> void:
    title_lbl.visible = en
    title_line.visible = en
    # title_spacer.visible = en

func get_option_nodes() -> Array:
    return options_container.get_children()

var title: String:
    set(value):
        title_lbl.text = value
    get:
        return title_lbl.text

var text: String:
    set(value):
        text_lbl.text = value
    get:
        return text_lbl.text

var visible_characters: int:
    set(value):
        text_lbl.visible_characters = value
    get:
        return text_lbl.visible_characters

var visible_ratio: float:
    set(value):
        text_lbl.visible_ratio = value
    get:
        return text_lbl.visible_ratio
    