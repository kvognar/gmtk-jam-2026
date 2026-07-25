extends Area2D
class_name RocketPanel

var locked := false

var total_bolts: int
var total_bolted := 0

signal finished

func _ready() -> void:
	$Sprite2D.modulate = Color('F7E28F')
	total_bolts = $Bolts.get_child_count()

func _on_click_and_drag_dropped() -> void:
	monitoring = true
	if !locked:
		%Hover.enable()
		$AudioStreamPlayer2D.play()

func _on_click_and_drag_lifted() -> void:
	monitoring = false
	%Hover.disable()

func _on_area_entered(area: Area2D) -> void:
	area.lock()
	global_position = area.global_position
	locked = true
	%Hover.disable()
	$Sprite2D.modulate = Color.WHITE;
	for bolt: Bolt in $Bolts.get_children():
		bolt.activate()
		bolt.bolted.connect(log_bolts)
	$ClickAndDrag.disable()
	
func log_bolts() -> void:
	total_bolted += 1
	if total_bolted >= total_bolts:
		finished.emit()
	
