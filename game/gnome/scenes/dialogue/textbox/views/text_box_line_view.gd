extends DialogueView

@export var text_box: TextBox

var _is_started: bool = false
var _is_running: bool = false

var _line: DialogueLine
var _on_line_finished: Callable
var _speaker: DialogueSpeakerRes

var _speed: float = 40.0:
    set(value):
        _speed = value
var _characters: float = 0.0

func _enter_tree() -> void:
    self.on_run_line.connect(_run_line)

func _ready() -> void:
    if not _is_started:
        text_box.toggle_lineview(false)

func _process(delta: float) -> void:
    if text_box.enabled and _is_started:
        if _is_running:
            # skip to end
            if Input.is_action_just_pressed("dia_skip"):
                _characters = text_box.text.length()
            # display text
            _characters += _speed * delta
            text_box.visible_characters = floori(_characters)
            if text_box.visible_ratio >= 1.0:
                _is_running = false
        # await user input
        else:
            if Input.is_action_just_pressed("dia_next"):
                if _on_line_finished.is_valid():
                    _on_line_finished.call()
                text_box.toggle_lineview(false)

func dialogue_started() -> void:
    _is_started = true
    self._runner.add_command_handler("speed", _handle_speed)

func dialogue_completed() -> void:
    _is_started = false
    self._runner.remove_command_handler("speed", _handle_speed)

func _run_line(line: DialogueLine, on_finished: Callable) -> void:
    _is_running = true

    text_box.toggle_lineview(true)
   
    _line = line
    text_box.toggle_title(true)
    text_box.text = _line.text
    text_box.visible_characters = 0
    _characters = 0.0
    
    _on_line_finished = on_finished
    
    _speaker = _runner.get_speaker(_line.speaker_id)
    text_box.title = _speaker.name
    if _speaker.show:
        text_box.toggle_speaker(true)
        text_box.speaker_icon.texture = _speaker.icon
    else:
        text_box.toggle_speaker(false)

func _handle_speed(cmd: DialogueCommand) -> void:
    var si := cmd.args[0]
    var i := int(si)
    if i == 0 and si != "0":
        assert(false, "Shouldn't happen lmfao.")
    self._speed = i

