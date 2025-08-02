extends DialogueView

@export var text_box: TextBox

func dialogue_started() -> void:
    text_box.box_show()
    
func dialogue_completed() -> void:
    text_box.box_hide()