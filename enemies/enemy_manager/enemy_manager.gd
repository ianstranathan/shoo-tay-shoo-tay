extends Node

@export var player_ref: CharacterBody2D:
	set = set_children_to_test_mobs


func set_children_to_test_mobs(_player_ref: CharacterBody2D):
	get_children().map( func(child): child.target = _player_ref)
