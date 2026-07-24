extends Resource
class_name Room

@export var name: String
@export var games: Array[PackedScene]
@export var preview: Texture2D = preload('res://icon.svg')
