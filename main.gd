extends Node

@export var the_player: CharacterBody2D
@export var level: Node2D
@export var the_shootay_manager: Node2D

func _ready() -> void:
	the_shootay_manager.wrapping_bounds = level.wrapping_bounds
	the_shootay_manager.shootay_collided.connect( func(pos: Vector2, normal: Vector2): 
		$vfx_container.make_collision_particle(pos, normal))
	the_player.shootay_manager = the_shootay_manager
	
	the_player.died.connect( game_over )
	
	$EnemyManager.player_ref = the_player

func game_over():
	# -- slow the tick rate way down for a minute, zoom in on how terrible
	# -- you are as a player
	# -- and restart
	pass
