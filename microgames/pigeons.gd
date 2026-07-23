extends Microgame

var total_pigeons := 0
var shooed_pigeons := 0

func _ready() -> void:
	for child: Pigeon in $Pigeons.get_children():
		child.shooed.connect(log_shoo)
		total_pigeons += 1
	
	super()
		

func log_shoo() -> void:
	shooed_pigeons += 1
	if shooed_pigeons >= total_pigeons:
		win()
	
