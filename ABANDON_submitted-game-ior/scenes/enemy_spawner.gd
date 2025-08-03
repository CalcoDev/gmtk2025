class_name EnemySpawner
extends Node2D

@export_group("UI References")
@export var score_label: RichTextLabel
@export var wave_announcement_label: RichTextLabel
@export var animation_player: AnimationPlayer

@export_group("Enemy Spawning")
@export var enemy_scene: PackedScene
@export var spawn_area_min: Vector2 = Vector2(-250, -160)
@export var spawn_area_max: Vector2 = Vector2(250, 160)

@export_group("Wave Configuration")
@export var base_enemies_per_wave: int = 3
@export var enemies_per_wave_increase: int = 2
@export var wave_announcement_duration: float = 3.0

var current_wave: int = 0
var current_score: int = 0
var enemies_killed_this_wave: int = 0
var total_enemies_this_wave: int = 0
var spawned_enemies: Array[Enemy] = []
var _is_starting_wave: bool = false

const GROUP_NAME := &"enemy_spawner"

static func get_instance(node: Node) -> EnemySpawner:
    return node.get_tree().get_first_node_in_group(GROUP_NAME)

func _notification(what: int) -> void:
    if what == NOTIFICATION_ENTER_TREE:
        add_to_group(GROUP_NAME)

func _ready() -> void:
    # Initialize UI
    if score_label:
        score_label.text = "Score: 0"
    
    if wave_announcement_label:
        wave_announcement_label.text = ""
        wave_announcement_label.visible = false
    
    # Start the first wave
    call_deferred("_start_next_wave")

func _process(_delta: float) -> void:
    # Clean up dead enemies from our tracking array
    _clean_up_dead_enemies()
    
    # Check if all enemies are dead and spawn new wave (but not if we're already starting one)
    if spawned_enemies.is_empty() and current_wave > 0 and not _is_starting_wave:
        _start_next_wave()

func _clean_up_dead_enemies() -> void:
    # Remove null/freed enemies from our tracking array
    spawned_enemies = spawned_enemies.filter(func(enemy): return is_instance_valid(enemy))

func _start_next_wave() -> void:
    # Prevent multiple simultaneous wave starts
    if _is_starting_wave:
        return
    
    _is_starting_wave = true
    current_wave += 1
    enemies_killed_this_wave = 0
    total_enemies_this_wave = base_enemies_per_wave + (current_wave - 1) * enemies_per_wave_increase
    
    # Show wave announcement
    _show_wave_announcement()
    
    # Wait for announcement duration then spawn enemies
    await get_tree().create_timer(wave_announcement_duration).timeout
    _spawn_enemies()
    
    # Allow next wave to start
    _is_starting_wave = false

func _show_wave_announcement() -> void:
    if not wave_announcement_label:
        return
    
    wave_announcement_label.text = "Wave " + str(current_wave)
    wave_announcement_label.visible = true
    
    # Play wave announcement animation if available
    if animation_player:
        animation_player.play("wave_announcement")
    
    # Hide announcement after duration
    get_tree().create_timer(wave_announcement_duration).timeout.connect(_hide_wave_announcement)

func _hide_wave_announcement() -> void:
    if wave_announcement_label:
        wave_announcement_label.visible = false

func _spawn_enemies() -> void:
    if not enemy_scene:
        print("Error: No enemy scene assigned to spawner!")
        return
    
    spawned_enemies.clear()
    
    for i in total_enemies_this_wave:
        var enemy_instance = enemy_scene.instantiate() as Enemy
        if not enemy_instance:
            print("Error: Failed to instantiate enemy!")
            continue
        
        # Random spawn position within the defined area
        var spawn_pos = Vector2(
            randf_range(spawn_area_min.x, spawn_area_max.x),
            randf_range(spawn_area_min.y, spawn_area_max.y)
        )
        
        enemy_instance.global_position = spawn_pos
        
        # Add to the designated spawn parent node
        var spawn_parent = get_tree().get_first_node_in_group("spawn_enemies_here")
        if spawn_parent:
            spawn_parent.add_child(enemy_instance)
        else:
            print("Warning: No node with group 'spawn_enemies_here' found, adding to current scene")
            get_tree().current_scene.add_child(enemy_instance)
        
        # Track this enemy
        spawned_enemies.append(enemy_instance)
        
        # Connect to enemy's tree_exiting signal to track kills
        enemy_instance.tree_exiting.connect(_on_enemy_killed)

func _on_enemy_killed() -> void:
    enemies_killed_this_wave += 1
    current_score += 10  # 10 points per enemy
    
    # Update score display
    if score_label:
        score_label.text = "Score: " + str(current_score)

func get_enemies_alive() -> int:
    _clean_up_dead_enemies()
    return spawned_enemies.size()

func get_current_wave() -> int:
    return current_wave

func get_current_score() -> int:
    return current_score
