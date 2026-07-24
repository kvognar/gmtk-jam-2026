extends Node3D

@export var shake_time: float = 0.6        # how long the rocket rattles when clicked
@export var shake_strength: float = 0.1    # rattle size IN METERS - keep it small
@export var play_scene: String = "res://scenes/intro.tscn"

@onready var ambiance: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var theme: AudioStreamPlayer2D = $music
@onready var rocket: Node3D = $rocket
@onready var rocket_area: Area3D = $rocket/Area3D
@onready var play_button: Button = %Play
@onready var quit_button: Button = %Quit

var rocket_home: Vector3
var rocket_on: bool = false
var busy: bool = false

func _ready():
	rocket_home = rocket.position
	ambiance.play()
	theme.play()
	rocket_area.input_event.connect(_on_rocket_clicked)

func _on_rocket_clicked(_camera, event, _position, _normal, _shape_idx) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if busy:
		return

	if rocket_on:
		rocket.off()
		rocket_on = false
	else:
		busy = true
		await shake_rocket(shake_time, shake_strength)
		rocket.ignite()
		rocket_on = true
		busy = false

func shake_rocket(duration: float, strength: float) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		rocket.position = rocket_home + Vector3(
			0,
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		await get_tree().create_timer(0.03).timeout
		elapsed += 0.03
	rocket.position = rocket_home

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(play_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
