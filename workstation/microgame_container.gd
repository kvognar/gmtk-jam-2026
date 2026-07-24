extends Node3D
class_name MicrogameContainer

var current_game: Microgame

@export var room: Room

var games: Array[PackedScene]
var current_game_index := 0

signal failure
signal success

func _ready() -> void:
	games = room.games
	prepare_game()
	if get_tree().root == get_parent():
		print_debug('running in test mode')
		start_game()

# We're using a TextureRect as a proxy for the viewport, so events need to be forwarded along
func _on_game_screen_gui_input(event: InputEvent) -> void:
	$SubViewport.push_input(event)
	
func prepare_game() -> void:
	current_game = games[current_game_index].instantiate()
	current_game_index += 1
	if current_game_index >= games.size():
		current_game_index = 0
	for child in $SubViewport.get_children():
		if !child.is_class('TextureRect'):
			child.queue_free()
	%PreviewImage.texture = room.preview
	$SubViewport.add_child(current_game)
	current_game.process_mode = Node.PROCESS_MODE_DISABLED

func start_game() -> void:
	current_game.begin()
	current_game.failure.connect(_on_game_fail)
	current_game.success.connect(_on_game_success)
	show_screen()
	current_game.process_mode = Node.PROCESS_MODE_INHERIT

func _on_game_fail() -> void:
	failure.emit()
	hide_screen()

func _on_game_success() -> void:
	success.emit()
	hide_screen()
	
func show_screen() -> void:
	$GameScreen.show()
	
func hide_screen() -> void:
	$GameScreen.hide()
	prepare_game()

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("action"):
		if !current_game:
			prepare_game()
		call_deferred('start_game')
