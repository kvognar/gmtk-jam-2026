extends Node2D

var start_position: Vector2
var end_position: Vector2
var active := false

var tape_sounds = [
	preload("res://assets/audio/tape1.ogg"),
	preload("res://assets/audio/tape2.ogg")
]

func _ready() -> void:
	$AudioStreamPlayer2D.stream = tape_sounds.pick_random()

func _process(_delta: float) -> void:
	
	if Input.is_action_pressed('action') and active:
		end_position = get_global_mouse_position()
		rotate_tape()
	
	if Input.is_action_just_released('action') and active:
		active = false
		%CollisionShape2D.disabled = false
	
	if Input.get_last_mouse_velocity().length() > 0 and active:
		if !$AudioStreamPlayer2D.playing && !$AudioStreamPlayer2D.stream_paused:
			$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D.stream_paused = false
	else:
		if active:
			$AudioStreamPlayer2D.stream_paused = true
		else:
			$AudioStreamPlayer2D.stop()

func rotate_tape() -> void:
	var texture: Texture2D = $Sprite2D.texture
	var height = texture.get_height()
	var target_height = (start_position - end_position).length()
	scale.y = target_height / height
	global_rotation = (end_position- start_position).normalized().rotated(PI/2).angle()
	
	global_position = (start_position + end_position) / 2
