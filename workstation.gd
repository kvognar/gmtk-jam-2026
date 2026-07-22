extends Node3D

var games: Array[Microgame] = []

func _process(delta: float) -> void:
	pass


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("action"):
		print_debug('monitor clicked!')
