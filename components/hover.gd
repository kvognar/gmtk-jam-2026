extends Node

@export var amplitude: float = 20
@export_range(0, 2 * PI) var angle := PI / 2

var base_position: Vector2
var elapsed_time := 0.0
var angle_vector: Vector2

func _ready() -> void:
	base_position = get_parent().global_position
	angle_vector = Vector2.from_angle(angle).normalized()
	

func _process(delta: float) -> void:
	elapsed_time += delta
	get_parent().global_position = base_position + (angle_vector * amplitude * sin(elapsed_time))
