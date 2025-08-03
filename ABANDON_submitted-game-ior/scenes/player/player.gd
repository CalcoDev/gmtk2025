extends CharacterBody2D

# @export var InputManager: Inp_manager_hidden

@export_group("References")
@export var anim: AnimatedSprite2D
@export var _dash_trail: Node2D

@export_group("Movement")
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0 * 2.0
@export var deceleration: float = 600.0 * 2.0
@export var turn_speed: float = 900.0 * 2.0

@export var walk_trail_duration: float = 0.1

@export_group("Dash")
@export var dash_cooldown: float = 0.25
@export var dash_duration: float = 0.2
@export var dash_speed: float = 20.0

@export var dash_trail_spawn_time: float = 0.05
@export var dash_trail_duration: float = 0.15
var _dash_trail_spawner_timer: float = 0.0
@export var dash_trail_color: Color

var is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO

var _prev_inp := Vector2.ZERO

@export_group("Weapons")
@export var _start_weapon: PackedScene

@export var _weapon_hold_spot: Marker2D

@export_group("Ball Interaction")
@export var ball_hit_force: float = 300.0
@export var ball_dash_force_multiplier: float = 2.0
@export var ball_spin_strength: float = 0.5

@export_group("Audio")
@export var footstep_interval: float = 0.4  # Seconds between footsteps
var _footstep_timer: float = 0.0

var _weapon: Weapon

const GROUP := &"playerlol"

static func get_instance(node: Node) -> KCamera:
    return node.get_tree().get_first_node_in_group(GROUP)

func _notification(what: int) -> void:
    if what == NOTIFICATION_ENTER_TREE:
        add_to_group(GROUP)

func _ready() -> void:
    _dash_trail.top_level = true
    if _start_weapon:
        _weapon = _start_weapon.instantiate()
        _weapon_hold_spot.add_child(_weapon)
        _is_ready_to_throw = false

        anim.animation_finished.connect(_weapon_animation_finished)

        # anim.sprite_frames.set_animation_speed(&"throw_prepare", weapon.use_cooldown)
        anim.sprite_frames.set_animation_speed(&"throw_prepare", float(anim.sprite_frames.get_frame_count(&"throw_prepare")) / _weapon.use_cooldown)
        anim.sprite_frames.set_animation_speed(&"throw_finish", float(anim.sprite_frames.get_frame_count(&"throw_finish")) / _weapon.use_cooldown)
        # print(anim.sprite_frames.get_animation_speed(&"throw_prepare"))
        anim.play(&"throw_prepare")

var __vel := Vector2.ZERO

var _is_throwing := false

var _is_ready_to_throw := false

func _weapon_animation_finished() -> void:
    if anim.animation == &"throw":
        anim.stop()
        _is_throwing = false
    elif anim.animation == &"throw_prepare":
        _is_ready_to_throw = true
    elif anim.animation == &"throw_finished":
        pass

var _weapon_recoil_offset := 0.0

func _process(delta: float) -> void:
    var inp := InputManager.data.move_vec

    # _downwell_lines_angle = lerp_angle(_downwell_lines_angle, InputManager.data.last_nonzero_move_vec.angle(), delta * 2.0)
    # _downwell_lines.material.set_shader_parameter("u_angle", _downwell_lines_angle)

    if _weapon:
        var d := {}
        if not is_dashing:
            var key := InputManager.data.primary
            if key.pressed or (_weapon.hold_downable and key.held):
                if _is_ready_to_throw and _weapon.can_use():
                    # _downwell_lines.material.set_shader_parameter("u_angle", (InputManager.data.mouse_pos - global_position).angle())
                    d = _weapon.use({
                        "is_bullet": true,
                        "position": global_position,
                        "bullet_direction": (InputManager.data.mouse_pos - global_position).normalized(),
                        "is_first_bullet": key.held_time > 0.1,
                        "parent_node": get_tree().get_first_node_in_group(&"bullets")
                    })
                    if d["shake"]:
                        var kcam := KCamera.get_instance(self)
                        kcam.shake_noise(_weapon.shake_freq, _weapon.shake_intensity, _weapon.shake_duration, true, kcam.process_callback)
                    if d["recoil"]:
                        _weapon_recoil_offset = d["recoil_intensity"]
                        # _weapon.get_child(0).get_child(0).position.x = _weapon_recoil_offset
                    anim.play(&"throw_finish")
                    _is_ready_to_throw = false
                    _is_throwing = true

        var parent := _weapon_hold_spot.get_parent() as Node2D

        var vp := get_viewport()
        var vp_size := vp.get_visible_rect().size
        var mp_normalised := ((vp.get_mouse_position() - vp_size * 0.5) / vp_size * 2.0).rotated(-parent.rotation)

        var w_pos := Vector2.ZERO
        if _weapon.rotate_pivot_self:
            if inp.x > 0.0:
                parent.scale.x = 1.0
            else:
                parent.scale.x = -1.0
        else:
            parent.rotation = (InputManager.data.mouse_pos - parent.global_position).angle()

            var mouse_offset := mp_normalised * (_weapon.hold_position_offset + _weapon.hold_position_min)
            w_pos = mouse_offset
            
            if parent.rotation < -PI / 2.0 or parent.rotation > PI / 2.0:
                _weapon.get_child(0).get_child(0).flip_v = true
            else:
                _weapon.get_child(0).get_child(0).flip_v = false
        _weapon.position = w_pos

        var elapsed_time := Time.get_ticks_msec() / 1000.0 * _weapon.bob_freq * 2.0
        
        # var inverse_mouse_mult := pow((1.0 - mp_normalised.length()), 0.5)
        var inverse_mouse_mult := 1.0 - pow(mp_normalised.length(), 3.0)

        var bob_offset := (Vector2.DOWN * sin(elapsed_time) * _weapon.bob_strength / 2.0) * inverse_mouse_mult

        _weapon.position += bob_offset 
        _weapon.rotation = sin(elapsed_time * _weapon.bob_rot_freq / 4.0) * deg_to_rad(_weapon.bob_rot_strength / 2.0) * inverse_mouse_mult

        var target_vel := self.velocity.normalized() * self.velocity.length_squared() / (max_speed * max_speed)
        __vel = __vel.lerp(target_vel, delta * 2.0)
        var vel_off := 8.0 * _weapon.bob_vel_delay *  __vel
        var c := _weapon.get_child(0)
        c.position = c.position.lerp(-parent.scale.y * vel_off.rotated(-parent.rotation), delta * 3.0)

        _weapon_recoil_offset = lerp(_weapon_recoil_offset, 0.0, 2.0 * delta)
        var cc := c.get_child(0)
        cc.position.x = _weapon_recoil_offset

        if "sparks" in d:
            for i in d["spark_count"]:
                var sparks := SparksRenderer.get_instance(self)
                sparks.spawn_spark(d["spark_pos"], d["spark_size"], d["spark_angle"] + randf() * d["spark_angle_random"], d["spark_speed"], d["spark_lifetime"])

    if is_dashing:
        anim.play(&"dash")
    elif anim.is_playing() and anim.animation in [&"throw_prepare", &"throw_finish", &"throw"]:
        pass
    elif _weapon != null and not _is_ready_to_throw:
        anim.play(&"throw_prepare")
    elif inp.length_squared() > 0.01:
        anim.play(&"run")
    else:
        var idle_anim := &"idle"
        if _weapon != null and _is_ready_to_throw:
            idle_anim = &"throw_prepared_idle"
        anim.play(idle_anim)
        
    if inp.length_squared() > 0.01:
        if inp.x > 0.0:
            anim.flip_h = false
        else:
            anim.flip_h = true
    else:
        var angle := (InputManager.data.mouse_pos - global_position).angle()
        if angle < -PI / 2.0 or angle > PI / 2.0:
            anim.flip_h = true
        else:
            anim.flip_h = false
    
    if not is_dashing and _dash_timer < 0.0 and InputManager.data.dash.pressed:
        _start_dash()
    _dash_timer -= delta
    if is_dashing:
        if _dash_timer < 0.0:
            _end_dash()

    # Footstep audio
    _footstep_timer -= delta
    if inp.length_squared() > 0.01 and not is_dashing and _footstep_timer <= 0.0:
        var sfx: AudioStreamPlayer2D = AudioManager.d["walk"] as AudioStreamPlayer2D
        if sfx:
            sfx.global_position = global_position
            sfx.play()
        _footstep_timer = footstep_interval

    # if is_dashing:
    _dash_trail_spawner_timer -= delta
    if _dash_trail_spawner_timer < 0.0:
        _dash_trail_spawner_timer = dash_trail_spawn_time

        _dash_trail_count += 1

        var duration := dash_trail_duration if is_dashing else walk_trail_duration
        if not is_dashing:
            if _dash_timer > 0.0:
                duration = 0.0
            if inp.length_squared() < 0.01:
                duration = 0.09

        var sprite := Sprite2D.new()
        sprite.texture = anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
        sprite.flip_h = anim.flip_h
        sprite.global_position = self.global_position
        sprite.modulate = dash_trail_color
        _dash_trail.add_child(sprite)
        var t := _dash_trail.create_tween()
        t.set_ease(Tween.EASE_IN_OUT)
        t.tween_method(_dash_sprite_update_callback.bind(sprite, _dash_trail_count), 0.0, 1.0, duration)
        t.parallel().tween_property(sprite, "scale", Vector2(0.8, 0.8), duration)
        t.tween_callback(_dash_sprite_free_callback.bind(sprite))
        t.play()

var _dash_trail_count: int = 0
func _dash_sprite_update_callback(_p: float, sprite: Sprite2D, index: int):
    var target := Color.TRANSPARENT.lerp(Color.WHITE, float(index) / float(_dash_trail_count))
    target.a *= 0.5
    if target.a < sprite.modulate.a:
        sprite.modulate.a = target.a

func _dash_sprite_free_callback(sprite: Sprite2D):
    sprite.queue_free()
    _dash_trail_count -= 1

func _physics_process(delta: float) -> void:
    var inp := InputManager.data.move_vec
    var body := self

    if is_dashing:
        body.velocity = _dash_dir * dash_speed * 10.0
        body.move_and_slide()
        if get_slide_collision_count() != 0:
            _end_dash()
    else:
        if not (abs(_prev_inp.x) > 0.0 and abs(_prev_inp.y) > 0.0) and abs(inp.x) > 0.0 and abs(inp.y) > 0.0:
            body.global_position = body.global_position.round()
        if inp.length_squared() > 0.0:
            var curr_dir := body.velocity.normalized()
            var target_dir := inp.normalized()
            var dot := curr_dir.dot(target_dir)
            if abs(dot) < 0.0:
                body.velocity = body.velocity.move_toward(Vector2.ZERO, turn_speed * delta)
            else:
                body.velocity = body.velocity.move_toward(target_dir * max_speed, acceleration * delta)
        else:
            body.velocity = body.velocity.move_toward(Vector2.ZERO, deceleration * delta)
        body.move_and_slide()
    
    for i in get_slide_collision_count():
        var coll := get_slide_collision(i)
        var ball := Ball.get_instance(self)
        if coll.get_collider() != ball:
            continue
        
        # Calculate impulse direction and strength
        var hit_direction := (ball.global_position - global_position).normalized()
        
        # Steer ball towards mouse cursor
        var mouse_direction := (InputManager.data.mouse_pos - ball.global_position).normalized()
        var steering_strength := 0.7  # How much to steer towards mouse (0.0 = no steering, 1.0 = full mouse direction)
        hit_direction = hit_direction.lerp(mouse_direction, steering_strength).normalized()
        
        var player_speed := velocity.length() * 0.9
        var player_velocity_component := velocity.dot(hit_direction)
        
        # Base force calculation - scale with player speed
        var speed_multiplier := player_speed / max_speed * 0.7 # Normalize speed to 0-1 range
        var force_magnitude := ball_hit_force * (0.5 + speed_multiplier * 0.5)  # Min 50%, max 100% based on speed
        
        # Add extra force based on how directly we're moving toward the ball
        if player_velocity_component > 0:
            force_magnitude += player_velocity_component * 1.0  # Increased from 0.5
        
        # Multiply force if dashing - much stronger effect
        if is_dashing:
            force_magnitude *= ball_dash_force_multiplier
            # Add dash velocity component for extra oomph
            var dash_velocity_component := (_dash_dir * dash_speed * 10.0).dot(hit_direction)
            if dash_velocity_component > 0:
                force_magnitude += dash_velocity_component * 0.3
        
        # Apply the impulse to the ball
        var impulse := hit_direction * force_magnitude
        
        # Calculate spin based on hit angle and player movement
        var hit_angle := velocity.angle_to(hit_direction)
        var spin_amount := sin(hit_angle) * ball_spin_strength
        
        if is_dashing:
            # Calculate how tangential the dash hit is
            var dash_angle := _dash_dir.angle_to(hit_direction)
            var tangent_factor: float = abs(sin(dash_angle))  # 0 = direct hit, 1 = perfectly tangential
            
            # For tangential hits: reduce force, massively increase spin
            if tangent_factor > 0.7:  # Highly tangential hit
                force_magnitude *= 0.3  # Drastically reduce force
                spin_amount *= 15.0 * tangent_factor  # Massive spin increase
                # Recalculate impulse with reduced force
                impulse = hit_direction * force_magnitude
            else:
                # Regular dash hit
                spin_amount *= 8.0  # Normal dash spin multiplier
            
            # Add additional spin based on dash direction vs hit direction
            spin_amount += sin(dash_angle) * ball_spin_strength * 5.0 * tangent_factor
        
        ball.apply_impulse(impulse, spin_amount)
        
        # Calculate feedback intensity based on force applied
        var force_intensity := force_magnitude / ball_hit_force  # Normalize to base force
        var hitstop_duration := 0.02 + (force_intensity * 0.08)  # 0.02-0.1 seconds based on force
        var shake_intensity := 2.0 + (force_intensity * 10.0)   # 20-100 shake intensity
        var shake_frequency := 10.0 + (force_intensity * 20.0)   # 10-30 shake frequency
        
        # Apply hitstop proportional to hit strength
        var v := maxf(0.01, minf(hitstop_duration, 0.25))
        hitstop(self, v)
        
        # Add some visual feedback
        var sparks := SparksRenderer.get_instance(self)
        var hit_point := coll.get_position()
        
        # Ball hit audio - volume scales with force
        var hit_volume := 0.5 + (force_intensity * 0.5)  # 0.5 to 1.0 volume based on force
        
        # Access audio nodes through the AudioManager singleton
        var ball_hit_sfx: AudioStreamPlayer2D = AudioManager.d["ball_hit"] as AudioStreamPlayer2D
        var ball_thomp_sfx: AudioStreamPlayer2D = AudioManager.d["ball_thomp"] as AudioStreamPlayer2D
        var ball_whine_sfx: AudioStreamPlayer2D = AudioManager.d["ball_whine"] as AudioStreamPlayer2D
        
        if ball_hit_sfx:
            ball_hit_sfx.global_position = hit_point
            ball_hit_sfx.volume_db = linear_to_db(hit_volume * 1.2)
            ball_hit_sfx.play()
        
        if ball_thomp_sfx:
            ball_thomp_sfx.global_position = hit_point
            ball_thomp_sfx.volume_db = linear_to_db(hit_volume * 0.8)  # Slightly quieter
            ball_thomp_sfx.play()
        
        if ball_whine_sfx:
            ball_whine_sfx.global_position = hit_point
            ball_whine_sfx.volume_db = linear_to_db(0.2)  # Small volume as requested
            ball_whine_sfx.play()
        
        var spark_count := int(3 + force_intensity * 7)  # 3-10 sparks based on force
        var spark_speed := 150.0 + (force_intensity * 200.0)  # 150-350 speed based on force
        var spark_size := Vector2(3.0, 3.0) + Vector2(force_intensity * 4.0, force_intensity * 4.0)  # 3x3 to 7x7 size
        for j in spark_count:
            sparks.spawn_spark(hit_point, spark_size, (-hit_direction).angle() + randf_range(-0.3, 0.3), spark_speed, 0.4)
        
        # Camera shake feedback proportional to force
        var kcam := KCamera.get_instance(self)
        kcam.shake_noise(shake_frequency, shake_intensity, 0.1 + (force_intensity * 0.1), true, kcam.process_callback)


    _prev_inp = inp

func _start_dash() -> void:
    is_dashing = true
    _dash_timer = dash_duration
    _dash_dir = InputManager.data.last_nonzero_move_vec
    _dash_trail_spawner_timer = 0.0
    
    var sparks := SparksRenderer.get_instance(self)
    sparks.spawn_spark(global_position, Vector2(12.0, 6.0) / 2.0, _dash_dir.angle() + PI / 4.0, 500.0, 0.6)
    sparks.spawn_spark(global_position, Vector2(12.0, 6.0) / 2.0, _dash_dir.angle() + PI / 4.0 + PI, 500.0, 0.6)
    for i in 8:
        sparks.spawn_spark(global_position, Vector2(4.0, 4.0), randf() * TAU, 200.0, 0.3)

    hitstop(self, 0.05)

    var dash_sfx: AudioStreamPlayer2D = AudioManager.d["dash"] as AudioStreamPlayer2D
    if dash_sfx:
        dash_sfx.global_position = global_position
        dash_sfx.play()

    var kcam := KCamera.get_instance(self)
    kcam.shake_spring(-_dash_dir * 200, 200.0, 10.0, kcam.process_callback)
    kcam.shake_noise(100, 10, 0.15, true, kcam.process_callback)

    # anim.hide()

func _end_dash() -> void:
    is_dashing = false
    _dash_timer = dash_cooldown
    self.velocity *= 0.5
    _dash_trail_spawner_timer = 0.0

    # anim.show()

static func hitstop(node: Node, duration: float, time_scale: float = 0.001) -> void:
    # var t := Engine.time_scale
    Engine.time_scale = time_scale
    await node.get_tree().create_timer(duration, true, false, true).timeout
    Engine.time_scale = 1.0