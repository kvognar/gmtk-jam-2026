extends Node


var current_game: Microgame

func _ready() -> void:
	%Microgame2.begin()

# We're using a TextureRect as a proxy for the viewport, so events need to be forwarded along
func _on_game_screen_gui_input(event: InputEvent) -> void:
	$SubViewport1.push_input(event)
