extends Area2D
class_name Bolt

var target_rotation := 5 * PI
var bolting := false
var affixed := false
var rotate_speed = 12 * PI

signal bolted

func _ready() -> void:
	if get_tree().root != get_parent():
		input_pickable = false

func activate() -> void:
	input_pickable = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed('action'):
		bolting = true

func _process(delta: float) -> void:
	if bolting:
		rotation += delta * rotate_speed
		if rotation >= target_rotation:
			bolting = false
			$AnimationPlayer.play('affix')
			affixed = true
			input_pickable = false
			bolted.emit()
		if Input.is_action_just_released('action'):
			bolting = false
