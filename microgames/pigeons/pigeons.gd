extends Microgame

var total_pigeons := 0
var shooed_pigeons := 0

func _ready() -> void:
	print_debug('pigeon time')
	for child: Pigeon in $Pigeons.get_children():
		child.shooed.connect(log_shoo)
		total_pigeons += 1
	
	super()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('action'):
		print_debug('i can hear you')
		print_debug(shooed_pigeons)
	super(_delta)
	#print_debug('pigeon?')

func log_shoo() -> void:
	shooed_pigeons += 1
	if shooed_pigeons >= total_pigeons:
		win()
	
