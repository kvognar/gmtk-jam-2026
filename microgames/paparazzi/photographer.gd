extends Pigeon

const COLORS: Array[Color] = [
	#Color('000000'),
	#Color('FFFFFF'),
	Color('3C779B'),
	#Color('A397AB'),
	Color('B0464E'),
	Color('F49E37'),
	Color('F7E28F')
]

func _ready() -> void:
	$Sprite2D.modulate = COLORS.pick_random()
