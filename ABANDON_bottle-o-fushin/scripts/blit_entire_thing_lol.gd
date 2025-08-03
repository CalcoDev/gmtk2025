@tool
extends Node

@export var word_prefab: PackedScene

@export var do_thing := false:
    set(value):
        do_thing = false

        for child in get_children():
            child.queue_free()

        depth = 0
        var d := parse_poem_to_tree(TEXT)
        print_ttree(d, 0, self)

var depth := 0
func print_ttree(node: Dictionary, indent: int, word_node: Node):
    var a := word_node
    if node["content"]:
        var phrase := Control.new()
        phrase.name = node["content"] + " PHRASE "
        word_node.add_child(phrase)
        if Engine.is_editor_hint():
            phrase.owner = get_tree().edited_scene_root
        phrase.size = Vector2.ZERO
        a = phrase

        var widx := 0
        for wwoorrdd: String in node["content"].split(" "):
            var txt := wwoorrdd.strip_edges().strip_escapes()
            widx += txt.length()
            var w := spawn_word(phrase)
            w.name += " WOOORD "
            w.global_position = Vector2.RIGHT * (indent * 100.0 + widx * 100) + Vector2.DOWN * 100 * depth
            w.text = txt

    depth += 1
    for child in node["children"]:
        print_ttree(child, indent + 1, a)
        depth += 1

func spawn_word(aa: Node) -> WordControl:
    var w := word_prefab.instantiate()
    aa.add_child(w)
    if Engine.is_editor_hint():
        w.owner = get_tree().edited_scene_root
    return w

const TEXT := """
Stuck
    In a bottle
        Staying still, in an algae alcove
            Kelpies peering through the waves
            Pushing you onwards
            Quails singing through the skies
            [a jump effect plays]
        Drifting endless, from shore to shore.
        Looking out, through the foggy, corroded, sanded glass
        The stars, carrying valiant light across the mist
            The swan arises and it asks
            What is it 123456780 seeks
                Perfect closure
                    Impossible to achieve.
                Imperfect end
                    Impossible to avoid
                Ever present sorrow
                    Impossible to outspeed
                Ephemeral happiness
                    Impossible to enlarge
            Shackled by blazing night
            Alone, this ray of light
            Made it’s way at your plight.
            You
                Stare
                    The Knight’s lance pierces deep
                    Like and OLED screen your retina burns.
                    The doctor asks for 200$.
                    [searing white flash]
                Blink
                    Photic retinopathy avoids your grasp.
                    Move back to the start, gain 200$.
                    [fall]
                Blonk.
                    Straddling the saddle
                    A great white horse walks by
                    Dejected in it’s dolour
                    It asks if you’re employed
                        Yes
                            Scoffing and gnawing at the ground
                            He leaves for greener pastures
                            And softer skies.
                            [fade to white]
                        No
                            Looking down at the scorched earth
                            It complains about the rain.
                            [falls with the rain]
                        Perchance
                            A hoof stamped business card appears in your 1234567890
                            Putting it closer
                            [retinopath? You can’t read / avoided retina damage? He plays the trumper]
                Blank.
                    It blanks back.
                    [screen consumed by a [] ]
        Empty void. Engulfed by abyss.
            Darkness drowned in dark solace
            Engulfed by pitch shifted light.
            Drowning in sorrows of
                Ancient blight [1]
                Unfound might [2]
            Hyades sing of what [will be 1] / [has been 2]
            A song of [WHITE]
    In a loop
        Loopily
        Bloopily
        Swirlily
        Twilrlily
        Scoopily
        Doodily
        Groovily (happy)
            Dancing and prancing
            Stepping and turning
            Waking and sleeping
            Awaiting tomorrow
            For it’s never ending.
        Gloobily (sad)
            Dragging and stumbling
            Tripping and halting
            Tossing and weeping
            Dreading the morning
            For it’s never ending
        [loop resets, but with changes]
        Loopily
        Bloopily…
        Swirlily…..
        …
        (happy: Always such fun / sad: + Where’s the fun…)
        (happy: Reciting them all / sad: + You’ve already seen them all…)
        …
        (happy: Round and round / sad: Again and again)
        (happy: We spin, we grin / sad: You fall, you crawl)
        (happy: But the fakeness of it all / sad: Let’s let them rest )
        (happy: It grips, it tears at your skin / sad: Feel themselves once more )
        By a lonely harbour wall
            She watched the last star fall
            For they lived and hoped and prayed
            For their campaign in ol’ Hudid
            It’s so lonely down the fields
            Of Oubia
            [low lie, the fields of Athenry, where once we watched the small, free birds fly…]
        By a towering crystal ball:
            Many questions you shall seek
            For the roots, they hold in deep
            Knowing naught of what will be yet
            Yet all of what it was
            And not even knowing
            That it is
            Oh and
            One last thing before you go
            Can you please tell me
            What is work?
                Love
                No more
            [both end in shots]
        By a solid, opaque glass wall:
            Dancing and stumbling
            Stepping and halting
            Tossing and sleeping
            Awaiting the morning
            For it’s never starting
            [first thing after preadmitere]
    In a room
        … I’ll add this later lmfao, I want to get some game work done I think.
        Didn’t get to explore nowhere near as much as I wanted (I basically said nothing for this entire time, which is annoying me, but I’ll figure it out)

"""

func parse_poem_to_tree(poem_text: String) -> Dictionary:
    var root = {"content": "", "children": [], "level": -1}
    var current_nodes = [root]
    var lines = poem_text.split("\n")
    
    for line in lines:
        # Count indentation (assuming 4 spaces per level)
        var indent_count = 0
        while line.begins_with("    "):
            indent_count += 1
            line = line.substr(4)
        
        # Remove leading/trailing whitespace from content
        var content = line.strip_edges()
        if content.is_empty():
            continue
        
        # Create new node
        var new_node = {"content": content, "children": [], "level": indent_count}
        
        # Find the appropriate parent based on indentation level
        while indent_count <= current_nodes[-1]["level"]:
            current_nodes.pop_back()
        
        # Add the new node as a child of the current parent
        current_nodes[-1]["children"].append(new_node)
        # Add the new node to the stack for potential children
        current_nodes.append(new_node)
    
    return root
