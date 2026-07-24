extends Node

@onready var current_player: AudioStreamPlayer = $Track1

func switch_to(new_song: AudioStream) -> void:
	if current_player == $Track1:
		$Track2.stream = new_song
		crossfade($Track1, $Track2)
	else:
		$Track1.stream = new_song
		crossfade($Track2, $Track1)

func crossfade(from_track: AudioStreamPlayer, to_track: AudioStreamPlayer) -> void:
	to_track.volume_db = -80.0
	
	var tween_out = get_tree().create_tween()
	tween_out.set_ease(Tween.EASE_IN)

	tween_out.tween_property(from_track, 'volume_db', -80.0, 0.5)
	var tween_in = get_tree().create_tween()
	tween_in.set_ease(Tween.EASE_OUT)

	tween_in.tween_property(to_track, 'volume_db', 0, 0.5)
	current_player = to_track
	to_track.play()
	tween_in.finished


#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed('action'):
		#if current_player == $Track1:
			#crossfade($Track1, $Track2)
		#else:
			#crossfade($Track2, $Track1)
