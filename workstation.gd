extends Node3D

var games: Array[Microgame] = []

var wins := 0
var losses := 0

func _ready() -> void:
	show_scores()

func _process(delta: float) -> void:
	pass

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("action"):
		$Microgame.begin()
		$Microgame.failure.connect(on_game_fail)
		$Microgame.success.connect(on_game_success)
		print_debug('monitor clicked!')

func on_game_fail() -> void:
	print_debug('oh no :(')
	losses += 1
	$Microgame.hide()
	show_scores()

func on_game_success() -> void:
	print_debug('woohoo')
	wins += 1
	$Microgame.hide()
	show_scores()

func show_scores() -> void:
	%Wins.text = 'Wins: ' + str(wins)
	%Losses.text = 'Losses: ' + str(losses)
