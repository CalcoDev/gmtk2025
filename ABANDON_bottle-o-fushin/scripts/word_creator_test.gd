@tool
extends Control

@export var do_thing := false:
    set(value):
        do_thing = false
        update_layout()

@export var word_prefab: PackedScene
@export var letter_prefab: PackedScene
@export var text: String = "" : set = set_text

@export_group("Layout Settings")
@export var word_spacing: float = 10.0
@export var letter_spacing: float = 2.0

func set_text(new_text: String):
    text = new_text
#     update_layout()

# func _ready():
# 	if Engine.is_editor_hint():
# 		update_layout()

func update_layout():
    # Clear existing children
    for child in get_children():
        child.queue_free()
    
    if !word_prefab or !letter_prefab or text.is_empty():
        return
    
    var words = text.split(" ", false)
    var current_x = 0.0
    
    for word_text in words:
        if word_text.is_empty():
            continue
            
        # Instantiate word node
        var word_node = word_prefab.instantiate()
        add_child(word_node)
        word_node.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
        
        # Position word node
        if word_node is Control:
            word_node.position.x = current_x
        elif word_node is Node2D:
            word_node.position.x = current_x
        
        var word_width = 0.0
        
        # Process each letter
        for letter in word_text:
            var letter_node = letter_prefab.instantiate()
            word_node.add_child(letter_node)
            letter_node.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
            
            # Set letter content (assuming letter prefab has a property like 'text')
            if letter_node.has_method("set_text"):
                letter_node.set_text(letter)
            
            # Position letter
            if letter_node is Control:
                letter_node.position.x = word_width
                if letter_node.size.x > 0:
                    word_width += letter_node.size.x + letter_spacing
            elif letter_node is Node2D:
                letter_node.position.x = word_width
                if letter_node.get("size") and letter_node.size.x > 0:
                    word_width += letter_node.size.x + letter_spacing
                else:
                    # Fallback if size not available
                    word_width += 20.0 + letter_spacing
        
        # Update current_x for next word
        current_x += word_width + word_spacing
    
    # Notify editor of changes
    if Engine.is_editor_hint():
        notify_property_list_changed()