extends Node

@export var the_player: CharacterBody2D
@export var level: Node2D
@export var the_shootay_manager: Node2D
@export var cam_ref: Camera2D

func _ready() -> void:
	# -- consolidate these signals with an optional arg
	the_shootay_manager.shootay_collided.connect( func(pos: Vector2, normal: Vector2): 
		$vfx_container.make_collision_particle(pos, normal))
	the_shootay_manager.transmission_collided.connect( func(pos: Vector2):
		the_player.teleport( pos ))

	the_shootay_manager.cam_ref = cam_ref
	the_shootay_manager.player_ref = the_player
	
	the_player.shot_a_shootay.connect( the_shootay_manager.make_shootay)
	the_player.died.connect( game_over )

	$EnemyManager.player_ref = the_player

	the_player.boosted.connect( func(pos: Vector2):
		# -- make a streak along this path
		
		# -- blur
		$PostProcessing.shockwave(pos))

func game_over():
	# -- slow the tick rate way down for a minute, zoom in on how terrible
	# -- you are as a player
	# -- and restart
	pass
