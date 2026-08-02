extends Node

var color: Color
var target: CanvasItem
@export var automatic: bool = true

func set_color(new_color: Color) -> void:
	color = new_color
	if automatic:
		assign_color()

func assign_color() -> void:
	if !color:
		print_debug('nevermind')
		return
	get_parent().modulate = color
