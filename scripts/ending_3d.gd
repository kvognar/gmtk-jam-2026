extends Node3D

@export var test_wins: int = 3
@export var test_losses: int = 0
@export var use_test_values: bool = true   # untick once your game feeds real numbers

@export_group("Intro")
@export var fade_time: float = 1.5        # how long the fade-from-black takes
@export var glide_time: float = 4.0       # camera flight up and over

@export_group("Rocket")
@export var shake_time: float = 1.0       # how long one burst of rattling lasts
@export var shake_strength: float = 0.1   # rattle size IN METERS - keep it small
@export var ignite_delay: float = 1.0     # smoke shows, then this pause before liftoff
@export var launch_time: float = 2.5      # seconds to climb to the top
@export var launch_height: float = 50.0   # how far up it flies (victory)
@export var lift_height: float = 8.0      # the little hop before it flops (semi)

@export_group("Camera")
@export var cam_start_pos: Vector3 = Vector3(0, 0.8, -0.2)
@export var cam_start_rot: Vector3 = Vector3(0, -90, 0)
@export var cam_end_pos: Vector3   = Vector3(12, 7, -0.2)
@export var cam_end_rot: Vector3 = Vector3(5,-90,0)
@export var cam_tilt_rot: Vector3  = Vector3(8, -90, 0)   # victory tilt

@onready var rocket: Node3D = %rocket
@onready var camera: Camera3D = %Camera
@onready var message: Label = %Label
@onready var fade: ColorRect = %Fade
@onready var outdoors: AudioStreamPlayer3D = %ambiance
@onready var indoors: AudioStreamPlayer3D = %ambiance2
@onready var title: Button = %"Return to Title"

var rocket_home: Vector3

var wins := 0
var losses := 0

func _ready():
	rocket_home = rocket.position

	camera.position = cam_start_pos
	camera.rotation_degrees = cam_start_rot
	camera.make_current() 
	outdoors.play()
	indoors.play()
	title.visible = false

	if message:
		message.visible = false

	if fade:
		fade.color.a = 1.0

	await fade_in()


func show_ending(victories: int, failures: int) -> void:
	wins = victories
	losses = failures
	await glide_camera()

#when these are global variables, switch them out
	if use_test_values:
		wins = get_wins()
		losses = get_losses()

#this is the current logic but feel free to make it anything, obvs
	if wins >= losses * 2:
		await ending_victory()
	elif wins >= losses:
		await ending_oops()
	else:
		await ending_worst()

func fade_in():
	if not fade:
		return
	var t := create_tween()
	t.tween_property(fade, "color:a", 0.0, fade_time)
	await t.finished

func glide_camera():
	var t := create_tween()
	t.tween_property(camera, "position", cam_end_pos, glide_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await t.finished

func ending_victory():
	await shake_rocket(shake_time, shake_strength)

	rocket.ignite()
	await get_tree().create_timer(ignite_delay).timeout
	rocket.burn()

	var fly := create_tween()
	fly.tween_property(rocket, "position", rocket_home + Vector3(0, launch_height, 0), launch_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	var tilt := create_tween()
	tilt.tween_property(camera, "rotation_degrees", cam_tilt_rot, launch_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await fly.finished
	
	show_message("HOT DOG THAT WAS GOOD")
	await get_tree().create_timer(.5).timeout
	rocket.off()
	title.visible = true

func ending_oops():
	await shake_rocket(shake_time, shake_strength)

	rocket.ignite()

	var up := create_tween()
	up.tween_property(rocket, "position", rocket_home + Vector3(0, lift_height, 0), 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await up.finished

	rocket.off()

	var fall := create_tween()
	fall.set_parallel(true)
	fall.tween_property(rocket, "position", Vector3(rocket_home.x, 1.35, rocket_home.z), 0.9) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_property(rocket, "rotation_degrees", Vector3(-92, 0, 0), 0.9) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await fall.finished

	show_message("OOPS THAT WASN'T GREAT")
	title.visible = true


func ending_worst():
	await shake_rocket(shake_time, shake_strength)
	rocket.ignite()
	await shake_rocket(shake_time, shake_strength * 2.0)
	await shake_rocket(shake_time, shake_strength * 3.5)
	rocket.off()
	await get_tree().create_timer(0.4).timeout
	show_message("OH NO THAT'S THE WORST")
	title.visible = true


func shake_rocket(duration: float, strength: float):
	var elapsed := 0.0
	while elapsed < duration:
		rocket.position = rocket_home + Vector3(0, randf_range(-strength, strength),randf_range(-strength, strength))
		await get_tree().create_timer(0.03).timeout
		elapsed += 0.03
	rocket.position = rocket_home

func show_message(text: String):
	message.text = text
	message.pivot_offset = message.size / 2.0
	message.scale = Vector2.ZERO
	message.visible = true

	var pop := create_tween()
	pop.tween_property(message, "scale", Vector2.ONE, 0.6) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

#all of this logic can go when wins and loses are global variables
func get_wins() -> int:
	if use_test_values:
		return test_wins
	return test_wins

func get_losses() -> int:
	if use_test_values:
		return test_losses
	return test_losses

func _on_return_to_title_pressed():
	get_tree().change_scene_to_file("res://scenes/title.tscn")
