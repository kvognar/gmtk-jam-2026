extends Node3D

#var games: Array[Microgame] = []
#var game_paks: Array[PackedScene] = [
	#load("res://microgames/suit_repair/suit_repair.tscn"),
	#load("res://microgames/pigeons.tscn"),
	#load("res://microgames/button_clicker.tscn"),
	#load("res://microgames/click_to_win.tscn"),
	#load("res://microgames/comms_game/comms.tscn")
#]

var current_game: Microgame

var wins := 0
var losses := 0

var game_index = 0

func _ready() -> void:
	show_scores()

func _process(_delta: float) -> void:
	pass

		
func start_game() -> void:
	current_game.begin()
	current_game.failure.connect(on_game_fail)
	current_game.success.connect(on_game_success)

func on_game_fail() -> void:
	losses += 1
	current_game.hide()
	show_scores()

func on_game_success() -> void:
	wins += 1
	current_game.hide()
	show_scores()

func show_scores() -> void:
	%Wins.text = 'Wins: ' + str(wins)
	%Losses.text = 'Losses: ' + str(losses)
