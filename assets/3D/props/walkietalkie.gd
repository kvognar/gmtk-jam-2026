extends Node3D
class_name WalkieTalkie

var queued_lines: Array[AudioStream] = []

func set_audio(audio: AudioStream) -> void:
	if $AudioStreamPlayer3D.playing:
		queued_lines.push_back(audio)
	else:
		$AudioStreamPlayer3D.stream = audio
		$AudioStreamPlayer3D.play()


func _on_audio_stream_player_3d_finished() -> void:
	$Cough.play()
	if !queued_lines.is_empty():
		await get_tree().create_timer(1).timeout
		$AudioStreamPlayer3D.stream = queued_lines.pop_front()
		$AudioStreamPlayer3D.play()
