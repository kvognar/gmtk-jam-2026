extends Node2D

@export var max_health: int = 50
var current_health = max_health

signal extinguished

func _on_area_2d_body_entered(body: Node2D) -> void:
	if current_health <= 0:
		return
	current_health -= 10
	var new_scale = float(current_health) / max_health
	scale = Vector2(new_scale, new_scale)
	if current_health <= 0:
		extinguished.emit(self)
