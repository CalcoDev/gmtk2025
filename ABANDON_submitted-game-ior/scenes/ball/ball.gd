class_name Ball
extends CharacterBody2D

const GROUP := &"ball"

static func get_instance(node: Node) -> Ball:
    return node.get_tree().get_first_node_in_group(GROUP)

@export_group("Physics")
@export var friction: float = 0.95
@export var bounce_damping: float = 0.8
@export var min_velocity_threshold: float = 10.0

@export_group("Spin")
@export var spin_decay: float = 0.98
@export var spin_influence: float = 150.0  # Increased from 50.0 for more dramatic curves
@export var max_spin_force: float = 300.0  # Maximum curve force per frame

@export_group("Audio")
@export var wind_min_speed: float = 50.0  # Minimum speed for wind sound
@export var wind_max_speed: float = 500.0  # Speed for maximum wind volume
@export var wind_max_volume: float = 0.8  # Maximum wind volume

var ball_velocity: Vector2 = Vector2.ZERO
var spin: float = 0.0  # Positive = clockwise, Negative = counter-clockwise
var _wind_sfx: AudioStreamPlayer2D

func _notification(what: int) -> void:
    if what == NOTIFICATION_ENTER_TREE:
        add_to_group(GROUP)

func _ready() -> void:
    # Initialize wind sound
    _wind_sfx = AudioManager.d["ball_wind"] as AudioStreamPlayer2D
    if _wind_sfx:
        _wind_sfx.volume_db = -80.0  # Start silent
        _wind_sfx.play()  # Start playing but silent

func _physics_process(delta: float) -> void:
    # Apply spin influence to velocity (enhanced curve mechanics)
    if abs(spin) > 0.01:
        # Calculate perpendicular force direction for curving
        var velocity_direction = ball_velocity.normalized()
        var perpendicular_force = Vector2(-velocity_direction.y, velocity_direction.x)
        
        # Apply spin force (positive spin = clockwise curve)
        var spin_force_magnitude = spin * spin_influence * delta
        spin_force_magnitude = clamp(spin_force_magnitude, -max_spin_force * delta, max_spin_force * delta)
        
        var spin_force = perpendicular_force * spin_force_magnitude
        ball_velocity += spin_force
        
        # Decay spin over time
        spin *= spin_decay
    
    # Apply friction
    ball_velocity *= friction
    
    # Stop very small movements to prevent jitter
    if ball_velocity.length() < min_velocity_threshold:
        ball_velocity = Vector2.ZERO
    
    # Set CharacterBody2D velocity and move
    velocity = ball_velocity
    move_and_slide()
    
    # Update wind sound based on ball speed
    if _wind_sfx:
        var current_speed = ball_velocity.length()
        _wind_sfx.global_position = global_position
        
        # Check if sound is still playing, if not restart it
        if not _wind_sfx.playing:
            _wind_sfx.play()
        
        if current_speed < wind_min_speed:
            # Too slow for wind sound
            _wind_sfx.volume_db = -80.0  # Effectively silent
        else:
            # Calculate volume based on speed
            var speed_ratio = (current_speed - wind_min_speed) / (wind_max_speed - wind_min_speed)
            speed_ratio = clamp(speed_ratio, 0.0, 1.0)
            var target_volume = speed_ratio * wind_max_volume
            _wind_sfx.volume_db = linear_to_db(target_volume)
    
    # Handle wall bounces
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        var normal = collision.get_normal()
        
        # Reflect velocity off the surface
        ball_velocity = ball_velocity.bounce(normal) * bounce_damping
        
        # Add some spin based on the collision angle (optional)
        var collision_angle = normal.angle_to(ball_velocity.normalized())
        spin += collision_angle * 0.1

func apply_impulse(impulse: Vector2, spin_amount: float = 0.0) -> void:
    """Apply an impulse to the ball and optionally add spin"""
    ball_velocity += impulse
    spin += spin_amount

func get_ball_velocity() -> Vector2:
    """Get the current ball velocity"""
    return ball_velocity

func get_spin() -> float:
    """Get the current ball spin"""
    return spin
