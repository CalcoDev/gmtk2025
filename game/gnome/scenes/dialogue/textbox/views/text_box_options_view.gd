extends DialogueView

@export var text_box: TextBox

var _is_started: bool = false
var _is_running: bool = false

var _options: Array[DialogueOption]
var _on_option_selected: Callable

var _selected_option_idx: int = 0 # the dalogue runner id

func dialogue_started() -> void:
    _is_started = true

func dialogue_completed() -> void:
    _is_started = false

var _option_nodes: Array

func _enter_tree() -> void:
    self.on_run_options.connect(_run_options)
    _option_nodes = text_box.get_option_nodes()

func _ready() -> void:
    if not _is_started:
        text_box.toggle_optionview(false)

func _process(_delta: float) -> void:
    if text_box.enabled and _is_started:
        if _is_running:
            # invert y because array yknow
            var inp_row := -1 * (int(Input.is_action_just_pressed("move_up")) - int(Input.is_action_just_pressed("move_down")))
            var old_idx := _selected_option_idx
            _selected_option_idx = (_options.size() + old_idx + inp_row) % _options.size()
            if _selected_option_idx != old_idx:
                _mark_unselected_option(_option_nodes[old_idx])
                _mark_selected_option(_option_nodes[_selected_option_idx])
            if Input.is_action_just_pressed("dia_next"):
                _on_option_selected.call(_selected_option_idx)
                text_box.toggle_optionview(false)

func _run_options(question: DialogueLine, options: Array[DialogueOption], on_selected: Callable) -> void:
    _is_running = true
    text_box.toggle_optionview(true)

    if question != null:
        text_box.toggle_title(true)
        text_box.title = question.text
    else:
        text_box.toggle_title(false)

    _options = options
    _on_option_selected = on_selected
    _selected_option_idx = _options[0].idx
    _show_opts()

func _show_opts() -> void:
    for option in _option_nodes:
        _hide_option(option)
    for option in _options:
        var option_node = _option_nodes[option.idx]
        _show_option(option_node)
        option_node.get_child(1).text = option.text
        if option.idx == _selected_option_idx:
            _mark_selected_option(option_node)

func _hide_option(option) -> void:
    option.visible = false
    option.get_child(0).visible = false

func _show_option(option) -> void:
    option.visible = true
    option.get_child(0).visible = false

func _mark_selected_option(option) -> void:
    option.get_child(0).visible = true

func _mark_unselected_option(option) -> void:
    option.get_child(0).visible = false
