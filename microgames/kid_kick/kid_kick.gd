extends Microgame
class_name KidKick

const POWER_GRACE = 10
const METER_SPEED = 0.5
const KICK_DURATION = 0.5
const ROTATION_SPEED = 2 * PI

var target_power: int
var on_target: bool = false
var animate_game: bool = true
var blasting_off: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() # Replace with function body.

func randomize_power_level() -> void:
	target_power = (randi() % 20) + 70

func adjust_kick_status(value: float) -> void:
	if on_target:
		$KickPrompt.show()
	else:
		$KickPrompt.hide()
	var rad_rotate = deg_to_rad(value)
	$FootPivot.rotation = rad_rotate

func win() -> void:
	super()
	animate_game = false
	start_kick()
	start_kid_timer()

func start_kid_timer() -> void:
	var kid_timer = Timer.new()
	kid_timer.wait_time = KICK_DURATION * 0.75
	kid_timer.connect('finished', _kid_blast_off_start)
	

func start_kick() -> void:
	var tween = $FootPivot.create_tween().bind_node($FootPivot)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($FootPivot, "rotation", deg_to_rad(-65), 0.5)
	tween.finished.connect(_kid_blast_off_start)
	
func _kid_blast_off_start() -> void:
	$KidOof.play()
	var tween = $KidSprite.create_tween().bind_node($KidSprite)
	blasting_off = true
	tween.tween_property($KidSprite, "position", Vector2(1800, 300), 0.75)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	var time_value = ($Timer.wait_time - $Timer.time_left) * METER_SPEED
	var value: float = abs(sin(time_value)) * $PowerMeter.max_value
	on_target = value >= target_power - POWER_GRACE && value <= target_power + POWER_GRACE
	if animate_game:
		adjust_kick_status(value)
		$PowerMeter.value =  value

	if Input.is_action_just_pressed('action') && playing:
		await win() if on_target else await fail()
		
	if blasting_off:
		$KidSprite.rotation += delta * ROTATION_SPEED
		

func begin() -> void:
	super()
	$KickPrompt.hide()
	randomize_power_level()
