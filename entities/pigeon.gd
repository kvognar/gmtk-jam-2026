extends CharacterBody2D
class_name Pigeon

enum STATES { waiting, fleeing }

var state: STATES = STATES.waiting

var flee_point: Vector2

signal shooed

func shoo(broom: Node2D) -> void:
	if state == STATES.waiting:
		state = STATES.fleeing
		var flee_vector = (global_position - broom.global_position).normalized()
		flee_point = global_position + flee_vector * 1000
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'global_position', flee_point, 1.0)
		shooed.emit()
		$AudioStreamPlayer2D.play()
