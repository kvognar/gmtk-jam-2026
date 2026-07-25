extends Microgame
var total_paparazzi := 0
var shooed_paparazzi := 0

func _ready():
	for child in $Photographers.get_children():
		total_paparazzi += 1
		child.shooed.connect(_log_shooed)
	super()
	
func _log_shooed() -> void:
	shooed_paparazzi +=1
	
	for player: AudioStreamPlayer in [$AudioStreamPlayer, $AudioStreamPlayer2]:
		var tween = get_tree().create_tween()
		var target_volume = ((total_paparazzi - shooed_paparazzi) / float(total_paparazzi))
		tween.tween_property(player, 'volume_linear', target_volume, 0.2)
	
	if shooed_paparazzi >= total_paparazzi:
		win()
