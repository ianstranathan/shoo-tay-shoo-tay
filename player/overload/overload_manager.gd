extends Node

signal overloaded

@export var player_sprite: Sprite2D
@onready var num_allowed_shots = ShootayGlobals.num_allowed_shots
var shootay_val
var stack = 0

func fune_fune_check(_shootay_val: ShootayGlobals.ShootayValues) -> void:
	# -- if the stack is @ the max and you try to fire 
	# -- again with the same type --> overload
	if stack == num_allowed_shots:
		type_fn(shootay_val == _shootay_val, 
				func(): emit_signal("overloaded"),
				func():
					increment_overload( -1 )
					if stack == 0:
						clear_overload())
	else:
		# -- otherwise, is it null or is a shootay type?
		if shootay_val == null:
			# -- if it's null, you just set it and increment the stack
			stack = 1
			shootay_val = _shootay_val
			if shootay_val == ShootayGlobals.ShootayValues.TRANSMIT:
				player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.transmit_col)
			else:
				player_sprite.material.set_shader_parameter("src_col", ShootayGlobals.reflect_col)
				
		# -- otherwise increment stack if it's the same type, otherwise decrease it
		else:
			type_fn(shootay_val == _shootay_val, 
					func(): increment_overload( 1 ),
					func():
						increment_overload( -1 )
						if stack == 0:
							clear_overload())


func type_fn( is_same_type: bool,
 			  yes_fn: Callable,
			  no_fn: Callable):
	if is_same_type:
		yes_fn.call()
	else:
		no_fn.call()


func increment_overload(inc: int):
	stack += inc
	overload_visual()


func overload_visual(clear=false):
	var _t = float(abs(stack)) / float(num_allowed_shots)
	player_sprite.material.set_shader_parameter("t", _t)
	if clear:
		player_sprite.material.set_shader_parameter("src_col", Color(1., 1., 1., 1.))


func clear_overload():
	stack = 0
	shootay_val = null
	overload_visual( true )
