class_name DialogueLine

@export var speaker_id: String
@export var text: String

@warning_ignore("shadowed_variable")
func _init(speaker_name: String, text: String) -> void:
    self.speaker_id = speaker_name
    self.text = text

func duplicate() -> DialogueLine:
    return DialogueLine.new(speaker_id, text)