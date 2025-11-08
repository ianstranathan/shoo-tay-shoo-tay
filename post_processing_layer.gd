extends CanvasLayer

@export var cam: Camera2D
var effects_fn_dict :Dictionary = {}
var do_effects: bool = false
func shockwave(position: Vector2):
	var duration = 1.0
	$ColorRect.visible = true
	var timer = get_tree().create_timer(duration)
	
	timer.timeout.connect( func(): 
		$ColorRect.visible = false	
		effects_fn_dict["shockwave"] = null
		should_do_effects()
	)
	
	# -- only need to call the offset once
	#$ColorRect.material.set_shader_parameter("offset", uv_pos(position))
	
	# -- functional closure around the timer
	effects_fn_dict["shockwave"] = func():
		var _t = 1. - timer.time_left
		$ColorRect.material.set_shader_parameter("t", _t)
	should_do_effects()


func uv_pos(global_pos: Vector2):
	var vp_size: Vector2i = cam.get_viewport().size
	return (global_pos - cam.global_position) / Vector2(vp_size.x, vp_size.y)


func should_do_effects():
	# -- && all things in dict (null is false in Godot)
	do_effects = effects_fn_dict.values().reduce( func(accum, val): return accum and val,
												  true)


func _process(delta: float) -> void:
	if do_effects:
		for fn in effects_fn_dict:
			effects_fn_dict[fn].call()
