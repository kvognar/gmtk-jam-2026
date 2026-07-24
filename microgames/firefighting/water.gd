extends CharacterBody2D

var health := 1.0

func _process(delta: float) -> void:
	health -= delta / 2
	scale = Vector2(health, health)
	move_and_slide()
	if health <= 0:
		queue_free()
