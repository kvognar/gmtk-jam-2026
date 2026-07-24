extends Node2D
class_name SuitHole

signal patched(hole: SuitHole)


func _ready() -> void:
	rotate(randf_range(0, 2*PI))


func _on_area_2d_area_entered(area: Area2D) -> void:
	var total_dist = 0
	for owner_idx in area.get_shape_owners():
		for shape_idx in area.shape_owner_get_shape_count(owner_idx):
			var other_shape = area.shape_owner_get_shape(owner_idx, shape_idx)
			var contacts = $Area2D/CollisionShape2D.shape.collide_and_get_contacts($Area2D/CollisionShape2D.global_transform, other_shape, area.global_transform * area.shape_owner_get_transform(owner_idx))
			for i in range(0, contacts.size(), 2):
				var a = contacts[i]
				var b = contacts[i+1]
				var dist = (b - a).length()
				total_dist += dist
	if ceil(total_dist) >= $Area2D/CollisionShape2D.shape.radius * 2:
		print_debug('patched!')
		patched.emit(self)
	else:
		print_debug('no good')
