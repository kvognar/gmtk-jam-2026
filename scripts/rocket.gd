extends Node3D

@onready var fire: Node3D = $fire
@onready var smoke: GPUParticles3D = $smoke

func _ready():
	off()

func ignite():
	smoke.visible = true
	fire.visible = false

func burn():
	fire.visible = true
	smoke.visible = false

func off():
	fire.visible = false
	smoke.visible = false
