class_name Enemy
extends CharacterBody2D

@export_group("Detection")
@export var detection_area: Area2D

@export_group("Animation")
@export var anim: AnimatedSprite2D
@export var animation_player: AnimationPlayer

@export_group("Ball Interaction")
@export var hit_force_min: float = 100.0
@export var hit_force_max: float = 300.0
@export var hit_force_random: float = 50.0  # Random variance in force
@export var aim_deviation: float = 0.3  # Maximum angle deviation in radians (±17 degrees)

@export_group("Movement AI")
@export var chase_speed: float = 150.0
@export var speed_variance: float = 50.0  # Random speed variance at spawn
@export var prediction_time: float = 0.5  # How far ahead to predict ball position
@export var intercept_distance: float = 80.0  # Desired distance from ball when intercepting
@export var activation_range: float = 400.0  # Range to start chasing ball
@export var wander_range: float = 100.0  # Maximum distance to wander from target position
@export var wander_change_interval: float = 2.0  # How often to change wander offset

@export_group("Swing Attack")
@export var swing_interval_min: float = 2.0  # Minimum time between swings
@export var swing_interval_max: float = 5.0  # Maximum time between swings
@export var swing_range: float = 60.0  # Range at which enemy will try to swing at ball

var _actual_chase_speed: float
var _wander_offset: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0
var _swing_timer: float = 0.0
var _next_swing_time: float

var _previous_position: Vector2
var _area_velocity: Vector2 = Vector2.ZERO
var _is_dead: bool = false

func _ready() -> void:
    _previous_position = global_position
    
    # Randomize speed at runtime
    _actual_chase_speed = chase_speed + randf_range(-speed_variance, speed_variance)
    _actual_chase_speed = max(_actual_chase_speed, 20.0)  # Minimum speed
    
    # Initialize wander offset
    _generate_new_wander_offset()
    
    # Initialize swing timing
    _reset_swing_timer()
    
    # Play hide animation if animation player is available
    if animation_player:
        animation_player.play("hide")
    
    # Connect to the area's body_entered signal
    if detection_area:
        detection_area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    # Don't do anything if dead
    if _is_dead:
        return
        
    # Track velocity by comparing positions
    if delta > 0.0:
        _area_velocity = (global_position - _previous_position) / delta
        _previous_position = global_position
    
    # Update swing timer
    _swing_timer += delta
    
    # AI movement to chase and intercept ball
    _chase_ball(delta)
    
    # Check for swing opportunities
    _check_swing_attack()

func _chase_ball(delta: float) -> void:
    # Update wander timer and generate new offset periodically
    _wander_timer += delta
    if _wander_timer >= wander_change_interval:
        _generate_new_wander_offset()
        _wander_timer = 0.0
    
    # Find the ball and player
    var ball = Ball.get_instance(self)
    var player = get_tree().get_first_node_in_group("playerlol")
    
    if not ball or not player:
        return
    
    # Check if ball is within activation range
    var distance_to_ball = global_position.distance_to(ball.global_position)
    if distance_to_ball > activation_range:
        return
    
    # Predict where the ball will be
    var ball_velocity = ball.get_ball_velocity()
    var predicted_ball_pos = ball.global_position + ball_velocity * prediction_time
    
    # Calculate ideal intercept position
    # We want to be positioned so we can hit the ball towards the player
    var ball_to_player = (player.global_position - predicted_ball_pos).normalized()
    var ideal_intercept_pos = predicted_ball_pos - ball_to_player * intercept_distance
    
    # Add wander offset to avoid convergence
    var target_pos = ideal_intercept_pos + _wander_offset
    
    # Move towards the target position
    var direction_to_target = (target_pos - global_position).normalized()
    var distance_to_target = global_position.distance_to(target_pos)
    
    # Only move if we're not close enough to the target position
    if distance_to_target > 20.0:
        velocity = direction_to_target * _actual_chase_speed
    else:
        velocity = Vector2.ZERO
    
    move_and_slide()
    
    # Handle animations
    _update_animations()

func _update_animations() -> void:
    if not anim:
        return
    
    # Check if moving
    if velocity.length_squared() > 10.0:  # Moving
        anim.play("run")
        # Flip sprite based on movement direction
        if velocity.x < 0:
            anim.flip_h = true
        else:
            anim.flip_h = false
    else:  # Not moving
        anim.play("idle")

func _generate_new_wander_offset() -> void:
    # Generate a random offset within the wander range
    var angle = randf() * TAU
    var distance = randf() * wander_range
    _wander_offset = Vector2.RIGHT.rotated(angle) * distance

func _on_body_entered(body: Node2D) -> void:
    # Don't do anything if already dead
    if _is_dead:
        return
        
    # Check if the body is the ball
    var ball = body as Ball
    if not ball:
        return
    
    # Enemy dies when hit by ball
    _die()

func _die() -> void:
    if _is_dead:
        return
    
    _is_dead = true
    
    # Disable collision detection
    if detection_area:
        detection_area.body_entered.disconnect(_on_body_entered)
        detection_area.set_deferred("monitoring", false)
    
    # Stop movement
    velocity = Vector2.ZERO
    
    # Play death animation
    if animation_player:
        animation_player.play("death")
        # Connect to animation finished to clean up
        if not animation_player.animation_finished.is_connected(_on_death_animation_finished):
            animation_player.animation_finished.connect(_on_death_animation_finished)
    else:
        # If no animation player, just remove immediately
        queue_free()

func _on_death_animation_finished(anim_name: StringName) -> void:
    if anim_name == "death":
        queue_free()

func _on_body_entered_old(body: Node2D) -> void:
    # Check if the body is the ball
    var ball = body as Ball
    if not ball:
        return
    
    # Calculate hit direction based on area velocity or fallback to random
    var hit_direction: Vector2
    
    # Find the player to aim towards
    var player = get_tree().get_first_node_in_group("playerlol")
    if player:
        # Aim towards player with some random deviation
        var to_player = (player.global_position - ball.global_position).normalized()
        var random_angle = randf_range(-aim_deviation, aim_deviation)
        hit_direction = to_player.rotated(random_angle)
    else:
        # Fallback to random direction if no player found
        hit_direction = Vector2.RIGHT.rotated(randf() * TAU)
    
    # Calculate random force magnitude
    var force_magnitude = randf_range(hit_force_min, hit_force_max) + randf_range(-hit_force_random, hit_force_random)
    var impulse = hit_direction * force_magnitude
    
    # Apply minimal spin (enemies don't spin as much as player)
    var spin_amount = randf_range(-0.2, 0.2)
    
    ball.apply_impulse(impulse, spin_amount)
    
    # Spawn visual effects (smaller and quieter than player)
    _spawn_hit_effects(ball.global_position, force_magnitude)

func _spawn_hit_effects(hit_point: Vector2, force_magnitude: float) -> void:
    # Calculate effect intensity (smaller than player effects)
    var force_intensity = force_magnitude / hit_force_max  # Normalize to 0-1
    
    # Spawn sparks (fewer and smaller than player)
    var sparks = SparksRenderer.get_instance(self)
    var spark_count = int(1 + force_intensity * 3)  # 1-4 sparks
    var spark_speed = 80.0 + (force_intensity * 100.0)  # 80-180 speed
    var spark_size = Vector2(2.0, 2.0) + Vector2(force_intensity * 2.0, force_intensity * 2.0)  # 2x2 to 4x4
    
    for i in spark_count:
        sparks.spawn_spark(hit_point, spark_size, randf() * TAU, spark_speed, 0.3)
    
    # Play audio effects (quieter than player)
    var hit_volume = 0.2 + (force_intensity * 0.3)  # 0.2 to 0.5 volume
    
    var ball_hit_sfx: AudioStreamPlayer2D = AudioManager.d["ball_hit"] as AudioStreamPlayer2D
    var ball_thomp_sfx: AudioStreamPlayer2D = AudioManager.d["ball_thomp"] as AudioStreamPlayer2D
    
    if ball_hit_sfx:
        ball_hit_sfx.global_position = hit_point
        ball_hit_sfx.volume_db = linear_to_db(hit_volume * 0.8)  # Quieter than player
        ball_hit_sfx.play()
    
    if ball_thomp_sfx:
        ball_thomp_sfx.global_position = hit_point
        ball_thomp_sfx.volume_db = linear_to_db(hit_volume * 0.6)  # Even quieter
        ball_thomp_sfx.play()

func _reset_swing_timer() -> void:
    _next_swing_time = randf_range(swing_interval_min, swing_interval_max)
    _swing_timer = 0.0

func _check_swing_attack() -> void:
    # Don't swing if dead
    if _is_dead:
        return
        
    # Only swing if enough time has passed
    if _swing_timer < _next_swing_time:
        return
    
    # Check if ball is in range
    var ball = Ball.get_instance(self)
    if not ball:
        return
    
    var distance_to_ball = global_position.distance_to(ball.global_position)
    if distance_to_ball <= swing_range:
        _perform_swing_attack()

func _perform_swing_attack() -> void:
    # Don't swing if dead
    if _is_dead:
        return
        
    # Reset swing timer for next swing
    _reset_swing_timer()
    
    # Play swing animation
    if animation_player:
        animation_player.play("swing")
    
    # Play swing sound effect
    var swing_sfx: AudioStreamPlayer2D = AudioManager.d["enemy_swing"] as AudioStreamPlayer2D
    if swing_sfx:
        swing_sfx.global_position = global_position
        swing_sfx.play()
    
    # Note: The actual ball hitting is handled by the detection_area's body_entered signal
    # The swing animation and sound are just visual/audio feedback
