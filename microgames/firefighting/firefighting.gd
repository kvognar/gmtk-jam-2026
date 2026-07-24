extends Microgame

var num_fires = 4
var fire_box = preload('res://microgames/firefighting/fire.tscn')
var fires_extinguished = 0

func _ready() -> void:
	for i in range(num_fires):
		var fire: Node2D = fire_box.instantiate()
		fire.extinguished.connect(_on_fire_extinguished)
		fire.global_position = Vector2(randf_range(100, 1500), randf_range(100, 600))
		$Fires.add_child(fire)
	super()

func _on_fire_extinguished(fire: Node2D) -> void:
	fire.queue_free()
	fires_extinguished += 1
	if fires_extinguished >= num_fires:
		win()
