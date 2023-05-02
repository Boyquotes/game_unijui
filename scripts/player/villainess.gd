extends CharacterBody2D

@onready var sprite: Sprite2D = get_node("Texture")

var is_dead: bool = false
var jump_count: int = 0
var is_on_double_jump: bool = false
var on_knockback = false
var max_health: float = 0.0
var knockback_direction: Vector2

@export var move_speed: float = 96.00
@export var jump_speed: float = -256.00
@export var gravity_speed: float = 512.00
@export var health: float = 25.0

func _ready() -> void:
	max_health = health

func _physics_process(delta) -> void:
	if is_dead == true:
		return
	if on_knockback == true:
		knockback_move()
		return
	move()
	velocity.y += delta * gravity_speed
	var _move := move_and_slide()
	jump()
	sprite.animate(velocity)
	
	if $Ray_Jump.is_colliding():
		var obj = $Ray_Jump.get_collider()
		if obj.is_in_group("enemy"):
			obj.damege()
			velocity.y = jump_speed

func knockback_move():
	velocity = knockback_direction * move_speed * 2
	var _move := move_and_slide()
	sprite.animate(velocity)

func move() -> void:
	var direction: float = get_direction()
	velocity.x = direction * move_speed

func get_direction() -> float:
	return(
		Input.get_axis("walk_left","walk_right")
	)

func jump() -> void:
	if is_on_floor():
		jump_count = 0
		is_on_double_jump = false
	if Input.is_action_just_pressed("jump") and jump_count < 2:
		velocity.y = jump_speed 
		jump_count += 1
	if jump_count == 2 and not is_on_double_jump:
		sprite.action_behavior("double_jump")
		is_on_double_jump = true

func update_health(_target_position: Vector2, value: int, type: String)-> void:
	if is_dead == true:
		return
	if type == "decrease":
		knockback_direction = (global_position - _target_position).normalized()
		sprite.action_behavior("hit")
		on_knockback = true
		health = clamp(health - value, 0, max_health)
		
		if health == 0:
			is_dead = true
			sprite.action_behavior("dead")
		return
	if type == "increase":
		health = clamp(health + value,0,max_health)



func on_hitbox_area_entered(area):
	if area.is_in_group("buraco"):
		is_dead = true
		sprite.action_behavior("dead")
		get_node("../CanvasLayer2/Game_over").visible = true
		transition_screen.fade_in()
