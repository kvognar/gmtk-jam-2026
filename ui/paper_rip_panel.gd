extends PanelContainer
class_name PaperRipPanel

var label: Label

@export_multiline var text: String:
	set(value):
		label.text = value

func _ready() -> void:
	if !label:
		label = %Label
		#label.text = text

func set_label(new_label) -> void:
	label = new_label
	for child in $MarginContainer.get_children():
		child.queue_free()
		$MarginContainer.add_child(label)
