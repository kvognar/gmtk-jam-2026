extends Control
class_name Microgame

@export var prompt: String = 'Do the thing!'
@export var time_limit := 5.0
@export var preview_image: Texture2D
@export var song: AudioStream
@export var hide_mouse := false

signal success
signal failure

var playing: bool = false


func _ready() -> void:
	scale = Vector2(0, 0)
	$Timer.wait_time = time_limit
		
	if get_parent() == get_tree().root:
		begin()

	
func _draw() -> void:
	pass

func begin() -> void:
	scale=Vector2(1, 1)
	%Prompt.set_text(prompt);
	%Prompt.show()
	%Result.hide()
	$Timer.start()
	if song:
		MusicPlayer.switch_to(song)
	$PromptTimer.start()
	await $PromptTimer.timeout
	%Prompt.hide()
	playing = true
	if hide_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func show_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func fail() -> void:
	playing = false
	await get_tree().create_timer(1.0).timeout
	failure.emit()
	show_mouse()

func lose() -> void:
	%Result.text = 'Oh no!'
	%Result.show()
	fail()
	
func win() -> void:
	if !playing:
		return
	%Result.text = 'Mission complete.'
	%Result.show()
	playing = false
	await get_tree().create_timer(1.0).timeout
	success.emit()
	show_mouse()
	
func _process(_delta: float) -> void:
	%ProgressBar.value = ($Timer.time_left / $Timer.wait_time) * %ProgressBar.max_value

func time_up() -> void:
	if !playing:
		return
	playing = false
	%Result.text = 'Time up!!'
	%Result.show()
	await get_tree().create_timer(1.0).timeout
	fail()

func _on_timer_timeout() -> void:
	time_up()
