extends Node2D


@export_enum("REFLECT", "TRANSMIT") var shootay_value: int:
	set = set_shootay_components


func _ready() -> void:
	set_shootay_components( shootay_value )


func set_shootay_components(val:int):
	assert( val in ShootayGlobals.valid_shootay_vals)
	$ShootayCollisionComponent.set_shootay_collision_mask(val)
	$ShootayColorComponent.set_shootay_visual(val)
