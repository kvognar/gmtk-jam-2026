class_name WarningLight
extends Node3D

## Expects an AnimationPlayer with a looping "alert" animation and an "off"
## animation, plus an AudioStreamPlayer3D named "beep". The alert animation
## calls _beep() from a method track on each flash.

signal alert_started
signal alert_cleared

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var beep: AudioStreamPlayer3D = $beep

@export var start_alerting := false
@export var fade_out := 0.25

var is_alerting := false

func _ready():
	anim.set_blend_time(&"alert", &"off", fade_out)
	if start_alerting:
		alert()
	else:
		anim.play(&"off")

func alert():
	if is_alerting:
		return
	is_alerting = true
	anim.play(&"alert")
	alert_started.emit()

func clear():
	if not is_alerting:
		return
	is_alerting = false
	anim.play(&"off")
	alert_cleared.emit()

func toggle():
	if is_alerting:
		clear()
	else:
		alert()

func _beep():
	beep.play()
