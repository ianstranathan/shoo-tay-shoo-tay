extends Node


@export var HUD: Control
func shoot(shootay_val: ShootayGlobals.ShootayValues):
	HUD.shoot(shootay_val)
	
func clear_shootay_meter():
	HUD.clear_shootay_meter()
