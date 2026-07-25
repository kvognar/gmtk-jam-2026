extends Microgame
class_name KidKick

const POWER_GRACE = 10
const METER_SPEED = 0.5
const KICK_DURATION = 0.5
const ROTATION_SPEED = 2 * PI

var target_power: int
var on_target: bool = false
var animate_game: bool = false
var blasting_off: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

func randomize_power_level() -> void:
	target_power = (randi() % 20) + 70

func adjust_kick_status(value: float) -> void:
	if on_target:
		$KickPrompt.show()
	else:
		$KickPrompt.hide()
	var rad_rotate = deg_to_rad(value)
	$FootPivot.rotation = rad_rotate

# reset state so that win() doesn't return early
func win_manual() -> void:
	playing = true
	win()

func start_end_sequence(winning: bool) -> void:
	$Timer.stop()
	$KickPrompt.hide()
	# disable input while the animation is playing
	playing = false
	start_kick(winning)
	start_kid_timer(winning)

func start_kid_timer(winning) -> void:
	var wait_time: float
	var callback: Callable
	if winning:
		wait_time = KICK_DURATION * 0.75
		callback = _kid_blast_off_start
	else:
		wait_time = KICK_DURATION * 0.25
		callback = _kid_evade_start
	$KidTimer.wait_time = wait_time
	$KidTimer.timeout.connect(callback)
	$KidTimer.start()
		

func start_kick(winning: bool) -> void:
	var tween: Tween = $FootPivot.create_tween().bind_node($FootPivot)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($FootPivot, "rotation", deg_to_rad(-65), 0.5)
	var callback: Callable = win_manual if winning else lose
	tween.tween_callback(callback).set_delay(0.5)
	
func _kid_blast_off_start() -> void:
	$KidTimer.stop()
	$KidOof.play()
	blasting_off = true
	var tween: Tween = $KidSprite.create_tween().bind_node($KidSprite)
	tween.tween_property($KidSprite, "position", Vector2(1800, 300), 0.75)

func _kid_evade_start() -> void:
	$KidTimer.stop()
	var position_tween: Tween = $KidSprite.create_tween().bind_node($KidSprite)
	var cur_pos: Vector2 = $KidSprite.position
	cur_pos.x -= 450
	position_tween.tween_property($KidSprite, "position", cur_pos, 0.5)
	var tbag_tween: Tween = $KidSprite.create_tween().bind_node($KidSprite).set_loops()
	tbag_tween.tween_callback(func(): $KidSprite.flip_h = !$KidSprite.flip_h).set_delay(0.15)
	lose()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if animate_game && playing:
		var time_value: float = ($Timer.wait_time - $PromptTimer.wait_time - $Timer.time_left) * METER_SPEED
		var value: float = abs(sin(time_value)) * $PowerMeter.max_value
		on_target = value >= target_power - POWER_GRACE && value <= target_power + POWER_GRACE
		adjust_kick_status(value)
		$PowerMeter.value =  value

	if Input.is_action_just_pressed('action') && playing:
		animate_game = false
		start_end_sequence(on_target)
			
	if blasting_off:
		$KidSprite.rotation += delta * ROTATION_SPEED
		

func begin() -> void:
	super()
	$KickPrompt.hide()
	randomize_power_level()

func _on_prompt_timer_timeout() -> void:
	animate_game = true
