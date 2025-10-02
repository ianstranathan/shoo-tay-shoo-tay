extends Node2D


@export var DEBUG: bool = true
func _input(event: InputEvent) -> void:
	if DEBUG and event.is_action("reset"):
		get
