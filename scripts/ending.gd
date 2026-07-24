extends Node2D

@export var test_wins: int = 3
@export var test_losses: int = 0
@export var use_test_values: bool = true   # untick once your game feeds real numbers

@export_group("Rocket")
@export var shake_time: float = 1.0       # how long the rocket rattles
@export var shake_strength: float = 4.0   # how violent the rattle is
@export var fire_delay: float = 0.5       # pause between flames appearing and lift-off
@export var launch_time: float = 2.0      # seconds to fly off the top of the screen
@export var hop_height: float = 90.0      # how far it gets in the "oops" ending
@export var tip_drop: float = 40.0        # how far it sinks as it tips over flat

@onready var rocket: Sprite2D = %rocket
@onready var fire: AnimatedSprite2D = %fire
@onready var cloud1: Sprite2D = %cloud1
@onready var cloud2: Sprite2D = %cloud2
@onready var message: Label = %Message
@onready var rocketburn: AudioStreamPlayer2D = %rocketburn
@onready var bonk: AudioStreamPlayer2D = %bonk
@onready var ambiance: AudioStreamPlayer2D = %ambiance



var rocket_home: Vector2
var screen_width: float

func _ready():
	ambiance.play()
	screen_width = get_viewport_rect().size.x
	rocket_home = rocket.position

	fire.visible = false
	message.visible = false

	#when wins and losses are a global variable swap these out
	var wins  := get_wins()
	var losses := get_losses()

	if wins >= losses * 2:
		await ending_victory()
	elif wins >= losses:
		await ending_oops()
	else:
		await ending_worst()

func _process(delta: float):
	cloud1.position.x += 25 * delta
	cloud2.position.x -= 18 * delta

func ending_victory():
	rocketburn.play()
	await shake_rocket(shake_time)

	fire.visible = true
	fire.play()
	
	await get_tree().create_timer(fire_delay).timeout

	var fly := create_tween()
	fly.tween_property(rocket, "position", rocket_home + Vector2(0, -1500), launch_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fly.finished
	fade_out_audio(rocketburn, 2)

	show_message("VICTORIOUS LAUNCH")

func ending_oops():
	rocketburn.play()
	await shake_rocket(shake_time)

	fire.visible = true
	fire.play()
	await get_tree().create_timer(fire_delay).timeout

	var up := create_tween()
	up.tween_property(rocket, "position", rocket_home + Vector2(0, -hop_height), 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await up.finished

	fire.stop()
	fire.visible = false
	rocketburn.stop()

	var down := create_tween()
	down.tween_property(rocket, "position", rocket_home, 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await down.finished
	
	var tip := create_tween()
	tip.set_parallel(true)
	tip.tween_property(rocket, "rotation_degrees", 90.0, 0.7) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tip.tween_property(rocket, "position", rocket_home + Vector2(0, tip_drop), 0.7)
	bonk.play()
	await tip.finished
	show_message("OOPS THAT WASN'T GREAT")

func ending_worst():
	rocketburn.play()
	await shake_rocket(shake_time)
	await get_tree().create_timer(0.5).timeout
	rocketburn.stop()
	show_message("OH NO THAT'S THE WORST")

func shake_rocket(duration: float):
	var elapsed := 0.0
	while elapsed < duration:
		rocket.position = rocket_home + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
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

#can delete these once wins/loses are global
func get_wins() -> int:
	if use_test_values:
		return test_wins
	return test_wins   # <-- change to your real source, e.g. Global.wins

func get_losses() -> int:
	if use_test_values:
		return test_losses
	return test_losses  # <-- change to your real source, e.g. Global.losses

func fade_out_audio(player: AudioStreamPlayer2D, duration: float):
	var start_volume := player.volume_db
	var fade := create_tween()
	fade.tween_property(player, "volume_db", -40.0, duration)
	await fade.finished
	player.stop()
	player.volume_db = start_volume
