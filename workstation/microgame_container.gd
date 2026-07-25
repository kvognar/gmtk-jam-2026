extends Node3D
class_name MicrogameContainer

var current_game: Microgame

@export var room: Room

var games: Array[PackedScene]
var current_game_index := 0
var running := false

signal failure
signal success

signal complete

func _ready() -> void:
	games = room.games
	prepare_game()
	if get_tree().root == get_parent():
		print_debug('running in test mode')
		start_game()
	
func prepare_game() -> void:
	if current_game_index >= games.size():
		current_game_index = 0

	current_game = games[current_game_index].instantiate()
	for child in %SubViewport.get_children():
		if !child.is_class('TextureRect'):
			child.queue_free()
	%PreviewImage.texture = room.preview
	%SubViewport.add_child(current_game)
	current_game.process_mode = Node.PROCESS_MODE_DISABLED

func start_game() -> void:
	fade_preview()
	current_game.begin()
	current_game.failure.connect(_on_game_fail)
	current_game.success.connect(_on_game_success)
	show_screen()
	running = true
	current_game.process_mode = Node.PROCESS_MODE_INHERIT
	
func fade_preview() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%PreviewImage, 'modulate', Color('ffffff00'), 0.5)
	tween.finished.connect(hidePreview)

func hidePreview() -> void:
	%PreviewImage.hide()

func _on_game_fail() -> void:
	failure.emit()
	hide_screen()

func _on_game_success() -> void:
	success.emit()
	hide_screen()
	
func show_screen() -> void:
	%GameScreen.show()
	
func hide_screen() -> void:
	running = false
	%GameScreen.hide()
	current_game_index += 1
	check_for_finished()
	prepare_game()

func check_for_finished() -> void:
	if current_game_index == games.size():
		complete.emit()


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("action"):
		if !current_game:
			prepare_game()
		call_deferred('start_game')
