extends Control
class_name Microgame

@export var prompt: String = 'Do the thing!'

signal success
signal failure

var playing: bool = false

func _ready() -> void:
	scale = Vector2(0, 0)

func begin() -> void:
	scale=Vector2(1, 1)
	$Prompt.text = prompt;
	$Prompt.show()
	$Result.hide()
	$Timer.start()
	await get_tree().create_timer(1.0).timeout
	$Prompt.hide()
	playing = true

func fail() -> void:
	print_debug('we lost :(')
	playing = false
	var timer = get_tree().create_timer(1.0).timeout
	print_debug('failure!!')
	failure.emit()

func lose() -> void:
	$Result.text = 'Oh no!'
	$Result.show()
	fail()
	
func win() -> void:
	if !playing:
		return
	$Result.text = 'You did it!'
	$Result.show()
	playing = false
	await get_tree().create_timer(1.0).timeout
	print_debug('on to the next thing')
	success.emit()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed('action'):
		win()

func time_up() -> void:
	if !playing:
		return
	playing = false
	print_debug('time_up')
	$Result.text = 'Time up!!'
	$Result.show()
	await get_tree().create_timer(1.0).timeout
	fail()

func _on_timer_timeout() -> void:
	time_up()
