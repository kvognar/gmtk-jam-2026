extends Microgame

var total_panels := 0
var panels_fixed := 0

func _ready() -> void:
	super()
	for panel: RocketPanel in $Panels.get_children():
		panel.finished.connect(log_panel_fix)

func log_panel_fix() -> void:
	panels_fixed += 1
	if panels_fixed >= total_panels:
		win()
