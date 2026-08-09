extends Node2D
class_name FrequencyDial
#
const CENTER = Vector2(100, 100)
const LABEL_LOCATION = Vector2(100, 200)
const LABEL_TEXT = "Freq"
const DIAL_RADIUS:int = 80
const GAUGE_RADIUS: float = DIAL_RADIUS * 0.9
# start should be less than end for the drawing to go correctly
const GAUGE_START:float =  5 * PI / 6
const GAUGE_END:float  = 13 * PI / 6
const DIAL_START: int = 1600
const DIAL_END: int = 2600
const DIAL_MARK_INTERVAL = 200
const DIAL_MARK_LENGTH = 10
const DIAL_WIDTH = 2.5

var dial_frequencies: Array[int]
var current_frequency: float = 0
var frequency_range: Vector2 = Vector2(0, 0)

func _ready():
	dial_frequencies = _compute_dial_frequencies()
	
func _draw():
	draw_dial_background()

func draw_dial_background() -> void:
	draw_circle(CENTER, DIAL_RADIUS, Color.FLORAL_WHITE, true)
	draw_arc(CENTER, GAUGE_RADIUS, GAUGE_START, GAUGE_END, 100, Color.BLACK)
	_draw_dial_marks()
	_draw_target_arc()
	_draw_current_dial()
	
	
func _draw_current_dial() -> void:
	var angle: float = _frequency_to_angle(current_frequency)
	var start_point: Vector2 = _polar_to_cartesian(angle, GAUGE_RADIUS)
	var to_center_vector = (CENTER - start_point).normalized()
	var dial_points = [-PI / 2, PI / 2].map(
		func(rot: float) -> Vector2:
			return CENTER + (to_center_vector.rotated(rot) * DIAL_WIDTH)
	)
	dial_points.push_back(start_point)
	draw_polygon(PackedVector2Array(dial_points), PackedColorArray([Color.RED]))

func _draw_dial_marks() -> void:
	for frequency in dial_frequencies: 
		var angle: float = _frequency_to_angle(frequency)
		var start_point: Vector2 = _polar_to_cartesian(angle, GAUGE_RADIUS)
		var endpoint_vector = (CENTER - start_point).normalized() * DIAL_MARK_LENGTH
		var endpoint = start_point + endpoint_vector
		draw_line(start_point, endpoint, Color.BLACK)

func _draw_target_arc() -> void:
	var start_freq = max(DIAL_START, frequency_range.x)
	var end_freq = min(DIAL_END, frequency_range.y)
	var start_angle = _frequency_to_angle(start_freq)
	var end_angle = _frequency_to_angle(end_freq)
	draw_arc(CENTER, GAUGE_RADIUS - 2.5, start_angle, end_angle, 100, Color.GREEN, 10)
	
func _compute_dial_frequencies() -> Array[int]:
	var frequencies: Array[int] = []
	var current_frequency = DIAL_START
	while current_frequency <= DIAL_END:
		frequencies.push_back(current_frequency)
		current_frequency += DIAL_MARK_INTERVAL

	return frequencies

func _frequency_to_angle(frequency: float) -> float:
	var result: float
	# gauge is limited, going too far literally doesn't move the needle any more
	if frequency <= DIAL_START:
		result = -GAUGE_START
	elif frequency >= DIAL_END:
		result = -GAUGE_END
	else:
		var progress = (frequency - DIAL_START) / (DIAL_END - DIAL_START)
		var angular_increment = progress * (GAUGE_END - GAUGE_START)
		result = -GAUGE_START - angular_increment
	
	result = -result
	return result

func _polar_to_cartesian(rad: float, radius: float, center: Vector2 = CENTER) -> Vector2:
	return (Vector2(1, 0).rotated(rad) * radius) + center

func set_frequency_range(range: Vector2) -> void:
	frequency_range = range
	queue_redraw()

func set_current_frequency(value: float) -> void:
	current_frequency = value
	queue_redraw()
	
