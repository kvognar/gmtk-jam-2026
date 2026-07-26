extends CharacterBody2D
class_name Pigeon

enum STATES { waiting, fleeing }

var state: STATES = STATES.waiting

var flee_point: Vector2

var waiting_animations = ['stand', 'walk']

@export var manual = true

signal shooed

func _ready() -> void:
	if !manual:
		$AnimatedSprite2D.play(waiting_animations.pick_random())

func shoo(broom: Node2D) -> void:
	if state == STATES.waiting:
		state = STATES.fleeing
		shooed.emit()
		if $AnimatedSprite2D.animation == 'nest':
			fall()
		else:
			fly_away(broom)

func fall() -> void:
	$AnimatedSprite2D.flip_h = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'global_position', global_position + Vector2(0, 800), 1)


func fly_away(broom: Node2D) -> void:
	$AnimatedSprite2D.play("fly")
	var flee_vector = (global_position - broom.global_position).normalized()
	flee_point = global_position + flee_vector * 1000
	$AnimatedSprite2D.flip_h = flee_point.x < global_position.x
	$AnimationPlayer.play("flap")
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'global_position', flee_point, 1.0)
	$AudioStreamPlayer2D.play()
