extends Microgame
class_name CommsGame

var degrees: int = 0
var target_frequency_range: Vector2i
var target_frequency: int
var current_frequency: float
var dial: Node
var is_dragging: bool = false
var angular_velocity: float = 0

const FREQ_CHANGE_RATE = 250.0
const ROTATION_RATE = 2 * PI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print_debug('different game')
	super()
	dial = $Radio/Dial/DialSprite
	
func begin() -> void:
	super()
	initialize_frequencies()
	update_current_frequency_text()
	$Static.play()
	$Timer.stop()

func initialize_frequencies() -> void:
	initialize_target_frequency()
	initialize_current_frequency()
		
func initialize_current_frequency() -> void:
	var frequency_offset = (randi() % 300) + 65
	var is_below = randf() <= 0.5
	current_frequency = target_frequency - frequency_offset if is_below else target_frequency + frequency_offset
	update_current_frequency_text()
	
func update_current_frequency_text() -> void:
	$CurrentFrequency.text = "Current: %2.f mHz" % current_frequency

func initialize_target_frequency() -> void:
	target_frequency = randi() % 100 + 2050
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
	if !playing:
		return
	$Radio/Dial/DialSprite.rotation += angular_velocity * delta * ROTATION_RATE
	if current_frequency >= target_frequency_range.x && current_frequency <= target_frequency_range.y && playing:
		win()

func _on_prompt_timer_timeout() -> void:
	$TargetFrequency.show()
	$CurrentFrequency.show()

func stop_dragging() -> void:
	is_dragging = false
	angular_velocity = 0

func _on_dial_mouse_exited() -> void:
	print_debug('mouse exited!!!')
	stop_dragging()

func _on_dial_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !playing:
		return
	
	if event is InputEventMouseButton:
		is_dragging = event.pressed
		if !is_dragging:
			stop_dragging()
	elif event is InputEventMouseMotion:
			if !is_dragging:
				return
			
			#var dial_center_to_mouse: Vector2 = event.position - $Radio/Dial.position
			var v1 = event.global_position
			#var directional_vector: Vector2 = v1 + event.relative
			#print_debug('debug', event.position, dial_center_to_mouse, rad_to_deg(directional_vector.angle()))
			var clockwise = is_clockwise(v1, event.relative)
			angular_velocity = -event.relative.angle() if clockwise else event.relative.angle()
			
# is other vector clockwise of base
# https://gamedev.stackexchange.com/questions/45412/understanding-math-used-to-determine-if-vector-is-clockwise-counterclockwise-f
func is_clockwise(base: Vector2, other: Vector2) -> bool:
	return base.y * other.x > base.x * other.y
