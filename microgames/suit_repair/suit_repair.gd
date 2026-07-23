extends Microgame

var tape_roll: PackedScene = preload("res://microgames/suit_repair/duct_tape.tscn")

var total_holes := 0
var patched_holes: Dictionary[SuitHole, bool] = {}

func _ready() -> void:
	for hole in $Suit/Holes.get_children():
		hole.patched.connect(log_hole_patched)
		total_holes += 1
	
	super()

func log_hole_patched(hole: SuitHole) -> void:
	patched_holes[hole] = true
	if patched_holes.size() >= total_holes:
		win()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action"):
		var tape = tape_roll.instantiate()
		$Tapes.add_child(tape)
		tape.active = true
		tape.start_position = get_global_mouse_position()
	
	super(delta)
		
		
