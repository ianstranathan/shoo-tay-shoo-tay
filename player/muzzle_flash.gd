extends Sprite2D


func _ready() -> void:
	visible = true


func muzzle_flash(shootay_value: ShootayGlobals.ShootayValues):
	#visible = true
	var tween = create_tween()
	#tween.tween_callback( func():
		#visible = false)
	Utils.shader_float_tween(tween, 
							self, 
							"t",
							0.0,
							1.0,
							0.5,
							Tween.EaseType.EASE_IN,
							Tween.TransitionType.TRANS_LINEAR)
