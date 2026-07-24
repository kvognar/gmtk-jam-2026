extends Node2D

var water_bottle: PackedScene = preload("res://microgames/firefighting/water.tscn")
var water_velocity: Vector2 = Vector2(0, -800)
@export var fire_rate: float = 0.1

var fire_delay = 0


func _process(delta: float) -> void:
	fire_delay -= delta
	if Input.is_action_pressed('action') and fire_delay <= 0:
		create_water()
	look_at(get_global_mouse_position())
	rotate(PI / 2)
	
func create_water() -> void:
	fire_delay = fire_rate
	var water: Node2D = water_bottle.instantiate()
	water.velocity = water_velocity.rotated(global_rotation)
	water.global_position = $Nozzle.global_position
	
	$Waters.add_child(water)
