extends Control

@export var shootay_meter: TextureRect


var t:int = 0

func _ready() -> void:
	visible = false
	clear_shootay_meter()


func clear_shootay_meter():
	t = 0
	shader_t_uniform()


func shoot(shootay_val: ShootayGlobals.ShootayValues):
	if shootay_val == ShootayGlobals.ShootayValues.REFLECT:
		t -= 1
	else:
		t += 1
	
	#assert(abs(t) <= ShootayGlobals.num_allowed_shots)
	shader_t_uniform()


func shader_t_uniform():
	shootay_meter.material.set_shader_parameter("t", float(t))
