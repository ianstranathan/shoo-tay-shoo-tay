extends GPUParticles2D

func _ready() -> void:
	finished.connect( func():
		visible = false)


func start_charging(shootay_type: ShootayGlobals.ShootayValues):
	process_material.color = ShootayGlobals.get_col(shootay_type)
	#amount = MIN_CHARGE_PARTICLES
	amount_ratio = 0.1
	emitting = true


func charge_up(ratio: float) -> void:
	amount_ratio = ratio


func stop_charging():
	emitting = false
