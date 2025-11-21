extends Node

signal overloaded

@export var num_switches_allowed: int = 3

@export var player_sprite: Sprite2D


var shootay_val
var num_shots_of_one_type_allowed: int = 3
var stack = 0

func fune_fune_check(_shootay_val: ShootayGlobals.ShootayValues) -> void:
	if shootay_val == null:
		shootay_val = _shootay_val
		stack += 1
		if shootay_val == ShootayGlobals.ShootayValues.TRANSMIT:
			player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.transmit_col)
		else:
			player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.reflect_col)
	else:
		if shootay_val == _shootay_val:
			increase_overload()
		else:
			decrease_overload()
		#if stack == 0:
			#player_sprite.material.set_shader_parameter("src_col", Color(1., 1., 1., 1.))

func increase_overload():
	increment_overload( 1 )


func decrease_overload():
	increment_overload( -1 )
	if stack == 0:
		clear_overload()


func increment_overload(inc: int):
	if stack <= num_shots_of_one_type_allowed and stack >= -num_shots_of_one_type_allowed:
		stack += inc
		var _t = float(abs(stack)) / float(num_shots_of_one_type_allowed - 1)
		player_sprite.material.set_shader_parameter("t", _t)
	else:
		assert( false )
		emit_signal("overloaded")

func clear_overload():
	stack = 0
	shootay_val = null
	player_sprite.material.set_shader_parameter("t", 0.0)
	player_sprite.material.set_shader_parameter("src_col", Color(1., 1., 1., 1.))


#func fune_fune_switch():
	#reset_overload()
	#if shootay_val == ShootayGlobals.ShootayValues.TRANSMIT:
		#shootay_val = ShootayGlobals.ShootayValues.REFLECT
		#player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.reflect_col)
	#else:
		#shootay_val = ShootayGlobals.ShootayValues.TRANSMIT
		#player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.transmit_col)


#func increase_overload():
	#if num_current_switches > num_switches_allowed:
		#emit_signal("overloaded")
	#else:
		#num_current_switches += 1
		#player_sprite.material.set_shader_parameter("t", float(num_current_switches) / float(num_switches_allowed))

#var num_current_switches: int = 0
#func reset_overload() -> void:
	#num_current_switches = 0
	#player_sprite.material.set_shader_parameter("t", 0.0)
	#
