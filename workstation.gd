extends Node3D

@export var song: AudioStream

@onready var countdown: AudioStreamPlayer3D = %countdown

var wins := 0
var losses := 0

var game_index = 0

var game_count_set := false
var total_games := 0

func _ready() -> void:
	MusicPlayer.switch_to(song)
	#countdown.play()
	show_scores()
	for container: MicrogameContainer in get_tree().get_nodes_in_group('microgame_containers'):
		if !game_count_set:
			total_games = container.games.size()
			%GamesLeftCounter.set_value(total_games)
			game_count_set = true
		container.failure.connect(_on_game_fail)
		container.success.connect(_on_game_success)
		container.complete.connect(_on_games_completed)

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

func _on_games_completed() -> void:
	await get_tree().create_timer(1.5).timeout
	%EndingOrchestrator.show_ending(wins, losses)
	print_debug('its all done')

func show_scores() -> void:
	%Wins.text = 'Wins: ' + str(wins)
	%Losses.text = 'Losses: ' + str(losses)
	%GamesLeftCounter.set_value(total_games - wins - losses)
