extends Node2D

signal game_over

@export var the_player: CharacterBody2D
@export var level: Node2D
@export var the_shootay_manager: Node2D
@export var cam_ref: Camera2D
@export var HUD: Control

func _ready() -> void:
	# -- consolidate these signals with an optional arg
	the_shootay_manager.shootay_collided.connect( func(pos: Vector2, normal: Vector2): 
		$vfx_container.make_collision_particle(pos, normal))
	#the_shootay_manager.transmission_collided.connect( func(pos: Vector2):
		#the_player.teleport( pos ))

	the_shootay_manager.cam_ref = cam_ref
	the_shootay_manager.player_ref = the_player
	
	# -- TODO
	# -- consolidate overloaded and died into the same callback with different
	# -- vfx responses
	the_player.overloaded.connect( func():
		# -- go through game over process with particular vfx
		# -- reset and hide everything
		# -- go back to menu and reintialize game
		emit_signal("game_over"))
	the_player.shot_a_shootay.connect( 
		func( pos: Vector2, dir: Vector2, shootay_value:ShootayGlobals.ShootayValues):
			the_shootay_manager.make_shootay.call(pos,  dir, shootay_value)
			HUD.shoot(shootay_value))
	the_player.died.connect( func():
		emit_signal("game_over"))

	the_player.started_dashing.connect( 
		func( _player: CharacterBody2D, dir: Vector2, speed: float, timer: Timer):
			$vfx_container.start_dash_effect(_player, dir, speed, timer))
	the_player.stopped_dashing.connect( func():
			$vfx_container.stop_dash_effect())
	# $EnemyManager.player_ref = the_player

	the_player.boosted.connect( func(pos: Vector2):
		# -- make a streak along this path
		
		# -- blur
		$PostProcessing.shockwave(pos))
	the_player.overload_cleared.connect( func(): 
		HUD.clear_shootay_meter() )


func start_game():
	pass


func quit_game():
	pass


func restart():
	# -- do a bunch of stuff for temporary / prototype restarts
	# -- try to put cleanup logic on the objects
	$DummiesContainer.get_children().map( func(child): child.set_marked( false ))
	$ShootayManager.get_children().map( func(child): child.queue_free() )
	the_player.restart()
	

#func game_over():
	## -- slow the tick rate way down for a minute, zoom in on how terrible
	## -- you are as a player
	## -- and restart
	#pass
