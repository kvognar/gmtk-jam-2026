extends Pigeon

const COLORS: Array[Color] = [
	#Color('000000'),
	#Color('FFFFFF'),
	Color('3C779B'),
	#Color('A397AB'),
	Color('B0464E'),
	Color('F49E37'),
	Color('F7E28F')
]

func _ready() -> void:
	pass
	#$Sprite2D.modulate = COLORS.pick_random()

func shoo(broom: Node2D) -> void:
	if state == STATES.waiting:
		state = STATES.fleeing
		fly_away(broom)
		shooed.emit()

func fly_away(broom: Node2D) -> void:
	var flee_vector = (global_position - broom.global_position).normalized()
	flee_point = global_position + flee_vector * 1000
	$Sprite2D.flip_h = flee_point.x < global_position.x
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'global_position', flee_point, 1.0)
