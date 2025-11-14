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


func make_a_packed_vec2_circle(num_pts: int, r: float) -> PackedVector2Array:
	var v: PackedVector2Array = []
	var theta = 0
	var delta_theta = TAU / float(num_pts)
	for i in range(num_pts):
		v.append( r * Vector2(cos(theta), sin(theta)))
		theta += delta_theta
	return v


func hit_stop(time_scale: float, duration: float):
	Engine.time_scale = time_scale
	await(get_tree().create_timer(duration * time_scale).timeout)
	Engine.time_scale = 1.0
