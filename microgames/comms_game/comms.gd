extends Microgame
class_name CommsGame

var degrees: int = 0
var target_frequency_range: Vector2i
var current_frequency: float
var dial: Node

const FREQ_CHANGE_RATE = 250.0
const ROTATION_RATE = PI / 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print_debug('different game')
	super()
	dial = $Icon
	#draw_dial()
	
func begin() -> void:
	super()
	initialize_frequencies()
	update_current_frequency_text()
	$Static.play()

func initialize_frequencies() -> void:
	initialize_current_frequency()
	update_current_frequency_text()
	initialize_target_frequency()
		
func initialize_current_frequency() -> void:
	var initial_frequency = (randi() % 1000) - 500
	current_frequency = 2050 + initial_frequency
	
func update_current_frequency_text() -> void:
	$CurrentFrequency.text = "Current: %2.f mHz" % current_frequency

func initialize_target_frequency() -> void:
	var target_frequency = randi() % 100 + 2050
	target_frequency_range = Vector2(target_frequency - 50, target_frequency + 50)
	$TargetFrequency.text = "Target: %s - %s mHz" % [target_frequency_range.x, target_frequency_range.y]

func update_frequency(increment) -> void:
	var new_frequency = current_frequency + increment
	if new_frequency < 0:
		new_frequency = 0
	current_frequency = new_frequency
	update_current_frequency_text()
	
func update_dial_rotation(rads) -> void:
	dial.rotation += rads

func win() -> void:
	$Static.stop()
	$VictoryVoice.play()
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Input.is_action_pressed("left"):
		var freq_increment = delta * FREQ_CHANGE_RATE * - 1
		update_frequency(freq_increment)
		var dial_rotation = delta * ROTATION_RATE * -1
		update_dial_rotation(dial_rotation)
	elif Input.is_action_pressed("right"):
		var freq_increment = delta * FREQ_CHANGE_RATE
		update_frequency(freq_increment)
		var dial_rotation = delta * ROTATION_RATE
		update_dial_rotation(dial_rotation)
	else:
		if current_frequency >= target_frequency_range.x && current_frequency <= target_frequency_range.y && playing:
			win()
			
		
	
