extends Node3D
class_name WalkieTalkie

func set_audio(audio: AudioStream) -> void:
	$AudioStreamPlayer3D.stream = audio
	$AudioStreamPlayer3D.play()
