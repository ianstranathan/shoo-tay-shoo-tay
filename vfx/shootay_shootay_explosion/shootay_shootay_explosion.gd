extends Node2D

#func _ready() -> void:
	#Utils.rng.randomize()
	#
	## -- feed seed to everything
	## -- I guess right now it's just the body
	#$body.material.set_shader_parameter("seed", TAU * Utils.rng.randf())
#
#
#func explode():
	#visible = true
	## -- body with a starting controller of 0.3 looks good for body, w/e
#
	#
	#var anim_tween = create_tween()
	#anim_tween.set_parallel(true)
	## -- explosion body exploding out
	#Utils.shader_float_tween(anim_tween, $flare, "alpha_controller",
							#1.0, 0., 0.15, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	#Utils.shader_float_tween(anim_tween, 
							#$contrast,
							#"alpha_controller",
							 #1.0,
							 #0.,
							 #0.35,
							 #Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	
	#var body_tween = create_tween()
	#Utils.shader_float_tween(anim_tween, 
							#$body,
							#"alpha_controller",
							 #0.3,
							 #1.0,
							 #0.7,
							 #Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	#anim_tween.chain().tween_callback( cleanup)
#
#func cleanup():
	#visible = false
	#$body.material.set_shader_parameter("alpha_controller", 0.3)
	#$flare.material.set_shader_parameter("alpha_controller", 1.0)
	#$contrast.material.set_shader_parameter("alpha_controller", 1.0)
#
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("SPACE"):
		#explode()
