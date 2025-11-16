extends Node

signal overloaded

@export var num_switches_allowed: int = 3
var num_current_switches: int = 0
@export var player_sprite: Sprite2D


var shootay_val

func fune_fune_check(_shootay_val: ShootayGlobals.ShootayValues) -> void:
	if shootay_val == null:
		shootay_val = _shootay_val
		if shootay_val == ShootayGlobals.ShootayValues.TRANSMIT:
			player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.transmit_col)
		else:
			player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.reflect_col)
	else:
		if _shootay_val != shootay_val:
			increase_overload()
		

func fune_fune_switch():
	reset_overload()
	if shootay_val == ShootayGlobals.ShootayValues.TRANSMIT:
		shootay_val = ShootayGlobals.ShootayValues.REFLECT
		player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.reflect_col)
	else:
		shootay_val = ShootayGlobals.ShootayValues.TRANSMIT
		player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.transmit_col)


func increase_overload():
	if num_current_switches > num_switches_allowed:
		emit_signal("overloaded")
	else:
		num_current_switches += 1
		player_sprite.material.set_shader_parameter("t", float(num_current_switches) / float(num_switches_allowed))


func reset_overload() -> void:
	num_current_switches = 0
	player_sprite.material.set_shader_parameter("t", 0.0)
	
