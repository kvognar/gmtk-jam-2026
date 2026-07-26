extends Area2D
class_name TetrisMover

@export var chair_enter_sound: AudioStream
@export var texture: Texture2D
@export var chair_position: Vector2
@export var is_winning: bool
@export var victory_scale: Vector2

func _ready() -> void:
	$TetrisSprite.texture = texture
	
