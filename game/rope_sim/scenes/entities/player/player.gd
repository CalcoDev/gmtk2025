extends CharacterBody2D

@export_group("References")
@export var _sprite: AnimatedSprite2D
@export var _anim: AnimationPlayer

@export_group("Movement")
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0 * 2.0
@export var deceleration: float = 600.0 * 2.0
@export var turn_speed: float = 900.0 * 2.0

@export_group("Dash")
@export var dash_cooldown: float = 0.25
@export var dash_duration: float = 0.2
@export var dash_speed: float = 20.0

var is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO

var _prev_inp := Vector2.ZERO

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    if not is_dashing and _dash_timer < 0.0 and InputManager.data.dash.pressed:
        _start_dash()
    _dash_timer -= delta
    if is_dashing:
        if _dash_timer < 0.0:
            _end_dash()
    
    if is_dashing:
        # _anim.play("dash")
        _sprite.play("dash")
    else:
        var inp := InputManager.data.move_vec
        if inp.length_squared() > 0.01:
            if abs(inp.y) > 0.01:
                _sprite.play(&"run_front" if inp.y > 0 else &"run_back")
            else:
                _sprite.play(&"run_side")
            _anim.play(&"waddle")
            if inp.x > 0.0:
                _sprite.flip_h = false
            else:
                _sprite.flip_h = true
        else:
            _anim.play(&"idle")
            _sprite.stop()
            _sprite.frame = 0

var _pullback_prev_vel := Vector2.ZERO
var _pulled_player_back := false
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
        if _pulled_player_back:
            velocity = _pullback_prev_vel
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

    _prev_inp = inp


func _start_dash() -> void:
    is_dashing = true
    _dash_timer = dash_duration
    _dash_dir = InputManager.data.last_nonzero_move_vec

    var kcam := KCamera.get_active(self)
    kcam.shake_spring(-_dash_dir * 200, 200.0, 10.0, kcam.process_callback)
    kcam.shake_noise(5, 5, 0.15, true, kcam.process_callback)

    var sparks := SparksRenderer.get_active(self)
    var angle := _dash_dir.angle() + PI / 4.0 - (PI / 8.0 * (randf() + 0.5))
    sparks.spawn_spark(global_position, Vector2(12.0, 6.0) / 2.0, angle, 500.0, 0.6)
    sparks.spawn_spark(global_position, Vector2(12.0, 6.0) / 2.0, angle + PI, 500.0, 0.6)
    for i in 8:
        sparks.spawn_spark(global_position, Vector2(4.0, 4.0), randf() * TAU, 200.0, 0.3)

func _end_dash() -> void:
    is_dashing = false
    _dash_timer = dash_cooldown
    self.velocity *= 0.5