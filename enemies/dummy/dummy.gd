extends Node2D

var transmit_mark_scene: PackedScene = preload("res://vfx/transmit_mark.tscn")

var marked: bool = false

func mark_for_teleport():
	marked = true
	var _mark = transmit_mark_scene.instantiate()
	add_child(_mark)
	_mark.global_position = global_position
