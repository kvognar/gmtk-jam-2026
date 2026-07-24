extends Node3D

@export var song: AudioStream

var wins := 0
var losses := 0

var game_index = 0

func _ready() -> void:
	MusicPlayer.switch_to(song)
	show_scores()
	for container: MicrogameContainer in get_tree().get_nodes_in_group('microgame_containers'):
		container.failure.connect(_on_game_fail)
		container.success.connect(_on_game_success)

func _process(_delta: float) -> void:
	pass

		
func _on_game_fail() -> void:
	MusicPlayer.switch_to(song)
	losses += 1
	show_scores()

func _on_game_success() -> void:
	MusicPlayer.switch_to(song)
	wins += 1
	show_scores()

func show_scores() -> void:
	%Wins.text = 'Wins: ' + str(wins)
	%Losses.text = 'Losses: ' + str(losses)
