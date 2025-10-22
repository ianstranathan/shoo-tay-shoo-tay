extends Node

@onready var rng = RandomNumberGenerator.new()

func uniform_float_fn(v: float, _surface, p: String):
	_surface.material.set_shader_parameter(p, v);


func shader_float_tween(tween: Tween,
						_surface,
						uniform_str: String,
						init_val: float,
						final_val: float,
						duration: float,
						easing_enum: Tween.EaseType,
						transition_enum: Tween.TransitionType):
	tween.tween_method(uniform_float_fn.bind(_surface, uniform_str),  
					   init_val,
					   final_val,
					   duration).set_trans(transition_enum).set_ease(easing_enum)


func normalized_timer(timer: Timer, reversed=false):
	var t = (timer.wait_time - timer.time_left) / timer.wait_time
	if reversed:
		return (1. - t)
	else:
		return t
