extends Area2D
class_name RocketPanel

var locked := false

var total_bolts: int
var total_bolted := 0

signal finished

func _ready() -> void:
	total_bolts = $Bolts.get_child_count()

func _on_click_and_drag_dropped() -> void:
	monitoring = true
	pass # Replace with function body.


func _on_click_and_drag_lifted() -> void:
	monitoring = false
	pass # Replace with function body.


func _on_area_entered(area: Area2D) -> void:
	area.lock()
	global_position = area.global_position
	locked = true
	for bolt: Bolt in $Bolts.get_children():
		bolt.activate()
		bolt.bolted.connect(log_bolts)
	$ClickAndDrag.disable()
	
	
func log_bolts() -> void:
	total_bolted += 1
	if total_bolted >= total_bolts:
		finished.emit()
	
