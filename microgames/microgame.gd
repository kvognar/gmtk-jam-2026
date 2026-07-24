extends Control
class_name Microgame

@export var prompt: String = 'Do the thing!'
@export var time_limit := 5.0
@export var preview_image: Texture2D

signal success
signal failure

var playing: bool = false

func _ready() -> void:
	scale = Vector2(0, 0)
	$Timer.wait_time = time_limit
	
	$PreviewImage.texture = preview_image
	
	if get_parent() == get_tree().root:
		begin()

func fade_preview() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($PreviewImage, 'modulate', Color('ffffff00'), 0.5)
	
func _draw() -> void:
	pass

func begin() -> void:
	print_debug('begin!!')
	fade_preview()
	scale=Vector2(1, 1)
	$Prompt.text = prompt;
	$Prompt.show()
	$Result.hide()
	$Timer.start()
	await get_tree().create_timer(1.0).timeout
	$Prompt.hide()
	playing = true

func fail() -> void:
	playing = false
	await get_tree().create_timer(1.0).timeout
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
	success.emit()
	
func _process(_delta: float) -> void:
	%ProgressBar.value = ($Timer.time_left / $Timer.wait_time) * %ProgressBar.max_value

func time_up() -> void:
	if !playing:
		return
	playing = false
	$Result.text = 'Time up!!'
	$Result.show()
	await get_tree().create_timer(1.0).timeout
	fail()

func _on_timer_timeout() -> void:
	time_up()
