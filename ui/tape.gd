extends PanelContainer
class_name Tape

@export var text: String

func _ready() -> void:
	%Label.text = text

func set_text(text) -> void:
	%Label.text = text
