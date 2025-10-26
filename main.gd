extends Node

@export var the_player: CharacterBody2D
@export var level: Node2D
@export var the_shootay_manager: Node2D

func _ready() -> void:
	the_shootay_manager.wrapping_bounds = level.wrapping_bounds
	the_player.shootay_manager = the_shootay_manager
	
	the_player.died.connect( game_over )
	
func game_over():
	pass
