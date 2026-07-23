extends Node2D

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	if Input.is_action_just_pressed('action'):
		$AnimationPlayer.play('swing')


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method('shoo'):
		body.shoo(self)
