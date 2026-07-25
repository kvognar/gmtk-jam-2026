extends Node2D

@export var max_health: int = 50
var current_health = max_health

var extinguish: AudioStream = preload("res://assets/audio/freesound_community-cig_extinguish-89851.mp3")

signal extinguished

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if current_health <= 0:
		return
	current_health -= 10
	var new_scale = float(current_health) / max_health
	scale = Vector2(new_scale, new_scale)
	$AudioStreamPlayer2D.volume_linear = new_scale
	if current_health <= 0:
		extinguished.emit(self)
		play_extinguish()
		
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed('action'):
		#play_extinguish()
#
func play_extinguish() -> void:
	print_debug('pssts')
	$AudioStreamPlayer2D.volume_linear = 1
	$AudioStreamPlayer2D.stream = extinguish
	$AudioStreamPlayer2D.play()
