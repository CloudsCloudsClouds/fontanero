extends KinematicBody2D

export var ui_up: String = "ui_up"
export var ui_down: String = "ui_down"
export var ui_left: String = "ui_left"
export var ui_right: String = "ui_right"
export var ui_attack: String = "ui_attack"
export var ui_start: String = "ui_start"

var velocity := Vector2.ZERO
export var jump_height := 10
export var jump_time := 0.3

var jump_force: float
var grav: float

var is_attack: bool = false

func _ready():
	grav = (2 * jump_height) / pow(jump_time, 2)
	jump_force = -(2 * jump_height) / jump_time


func _physics_process(delta):
	if is_attack:
		attack(delta)
	elif !is_attack:
		move(delta)


func move(delta):
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.7853, false)
	
	var inp_map = Input.get_action_strength(ui_right) - Input.get_action_strength(ui_left)
	
	if is_on_floor():
		if Input.is_action_just_pressed(ui_up):
			velocity.y = jump_force
			get_tree().call_group("audio", "play_jump")
		
		if Input.is_action_just_pressed(ui_attack):
			is_attack = true
	
	velocity.y = clamp(velocity.y + grav * delta, -300, 100)
	
	velocity.x = 35 * inp_map 
	
	anim()
	$Pusher.constant_linear_velocity = velocity / 2


func attack(delta):
	velocity.x = 0
	if !$AnimatedSprite.animation == "punch":
		$AnimatedSprite.play("punch")
		get_tree().call_group("audio", "play_swing")
	
	if $AnimatedSprite.frame == 0:
		$AnimatedSprite.speed_scale = 2
	elif $AnimatedSprite.frame == 1:
		$AnimatedSprite.speed_scale = 1
	elif $AnimatedSprite.frame == 2:
		$AnimatedSprite.speed_scale = 2
		$PunchArea/CollisionShape2D.disabled = false
	elif $AnimatedSprite.frame == 3:
		$AnimatedSprite.speed_scale = 1


func anim():
	match sign(velocity.x):
		-1.0:
			$AnimatedSprite.flip_h = true
			$PunchArea.scale.x = -1
		1.0:
			$AnimatedSprite.flip_h = false
			$PunchArea.scale.x = 1


	if velocity.x != 0:
		$AnimatedSprite.play("move")
	else:
		$AnimatedSprite.play("idle")
	
	if !is_on_floor():
		$AnimatedSprite.play("jump")
	


func _on_AnimatedSprite_animation_finished():
	if is_attack:
		is_attack = !is_attack
		$AnimatedSprite.speed_scale = 1
		$PunchArea/CollisionShape2D.disabled = true
		$PunchArea.can_waterget = false
