extends Control
class_name Microgame

@export var prompt: String = 'Do the thing!'
@export var time_limit := 5.0
@export var preview_image: Texture2D
@export var song: AudioStream
@export var hide_mouse := false
@export var intro_line: AudioStream
@export var win_line: AudioStream
@export var lose_line: AudioStream

@export var win_time := 1.0
@export var lose_time := 1.0

signal success
signal failure

var playing: bool = false

func _ready() -> void:
	modulate.a = 0
	$Timer.wait_time = time_limit
	if get_parent() == get_tree().root:
		begin()
	
func _draw() -> void:
	pass

func begin() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'modulate:a', 1.0, 0.3)
	%Prompt.set_text(prompt);
	%Prompt.show()
	%ResultContainer.hide()
	$Timer.start()
	if song:
		MusicPlayer.switch_to(song)
	else:
		MusicPlayer.hush()
	$PromptTimer.start()
	await $PromptTimer.timeout
	get_tree().create_tween().tween_property(%Prompt, 'modulate:a', 0, 0.5)
	#%Prompt.hide()
	playing = true
	if hide_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func show_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func fail() -> void:
	if !playing:
		return
	playing = false
	radio_loss()
	await get_tree().create_timer(lose_time).timeout
	failure.emit()
	show_mouse()

func lose() -> void:
	%Result.text = 'Oh no!'
	%ResultContainer.show()
	fail()
	
func win() -> void:
	if !playing:
		return
	%Result.text = 'Mission complete.'
	%ResultContainer.show()
	playing = false
	await get_tree().create_timer(win_time).timeout
	success.emit()
	show_mouse()
	
func _process(_delta: float) -> void:
	%ProgressBar.value = ($Timer.time_left / $Timer.wait_time) * %ProgressBar.max_value

func time_up() -> void:
	if !playing:
		return
	%Result.text = 'Time up!!'
	%ResultContainer.show()
	fail()

func radio_loss() -> void:
	if lose_line:
		var radio: WalkieTalkie = get_tree().get_first_node_in_group('walkie_talkie')
		if radio:
			radio.set_audio(lose_line)

func _on_timer_timeout() -> void:
	time_up()
