extends Node

@export var amplitude: float = 20
@export_range(0, 2 * PI) var angle := PI / 2

var base_position: Vector2
var elapsed_time := 0.0
var angle_vector: Vector2
var enabled := true

func _ready() -> void:
	base_position = get_parent().position
	angle_vector = Vector2.from_angle(angle).normalized()
	

func _process(delta: float) -> void:
	if enabled:
		elapsed_time += delta
		get_parent().position = base_position + (angle_vector * amplitude * sin(elapsed_time))

func disable() -> void:
	enabled = false 
	elapsed_time = 0
	get_parent().position = base_position

func enable() -> void:
	enabled = true
