extends Node3D

@onready var fire: Node3D = $fire
@onready var smoke: GPUParticles3D = $smoke
@onready var burn_sound: AudioStreamPlayer3D = $burn

func _ready():
	off()

func ignite():
	burn_sound.play()
	smoke.visible = true
	fire.visible = false

func burn():
	fire.visible = true
	smoke.visible = false

func off():
	burn_sound.stop()
	fire.visible = false
	smoke.visible = false
