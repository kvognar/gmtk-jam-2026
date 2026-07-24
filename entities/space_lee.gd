extends Node2D

func happy() -> void:
	$AnimatedSprite2D.play('happy')

func sad() -> void:
	$AnimatedSprite2D.play('sad')
