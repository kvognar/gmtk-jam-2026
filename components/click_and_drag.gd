extends Node2D

var parent: Node2D

var offset: Vector2
var held := false
var disabled := false

signal dropped
signal lifted

func _ready() -> void:
	parent = get_parent()

func disable() -> void:
	disabled = true
	$Area2D/CollisionShape2D.set_deferred('disabled', true)

func _process(_delta: float) -> void:
	if held:
		parent.global_position = get_global_mouse_position() + offset
	if Input.is_action_just_released('action'):
		held = false
		dropped.emit()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed('action'):
		get_tree().root.set_input_as_handled()
		if !held:
			lifted.emit()
			held = true
			offset = parent.global_position - get_global_mouse_position()
