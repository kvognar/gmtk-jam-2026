extends Control
class_name Microgame

@export var prompt: String = 'Do the thing!'

signal success
signal failure

func _ready() -> void:
	begin()

func begin() -> void:
	$Prompt.text = prompt;

func fail() -> void:
	failure.emit()
	
func win() -> void:
	success.emit()
