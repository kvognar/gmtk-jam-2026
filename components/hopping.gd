extends Node

var parent: Sprite2D
var starting_position: Vector2

@export var gravity: float
@export var impulse: float
@export var min_jump_wait: float
@export var max_jump_wait: float

var velocity: float
var wait_time: float
var jumping := false

func _ready() -> void:
	parent = get_parent()
	starting_position = parent.position
	reset_wait()

func _process(delta: float) -> void:
	wait_time -= delta
	if wait_time <= 0 && !jumping:
		reset_wait()
		jump()
	
	parent.position.y += velocity * delta
	if parent.position.y > starting_position.y:
		parent.position.y = starting_position.y
		velocity = 0
		jumping = false
	velocity += gravity * delta

func jump() -> void:
	velocity = -impulse
	jumping = true
	parent.flip_h = !parent.flip_h

func reset_wait() -> void:
	wait_time = randf_range(min_jump_wait, max_jump_wait)
