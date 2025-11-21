extends Control

@export var shootay_meter: TextureRect

# -- TODO
# -- Magic number of 0.33 needs to change to 1. / N shots
# -- where N is decided elsewhere in program 
# -- (the number of shots of one type that is allowed )
var t = 0.0
func _ready() -> void:
	#var _size = $TextureRect.scale * $TextureRect.texture.get_size()
	print( size )
	var vp_dim = get_viewport().size
	
	# -- TODO
	# -- magic number size.x / 8. => make it adjustable
	# -- (it's coming from the fact that I chose to scale the texture rect by half and
	# --  the anchors are making it full screen)
	$TextureRect.position = Vector2((vp_dim.x / 2.0) - size.x / 8., 0.9 * vp_dim.y)
	shootay_meter.material.set_shader_parameter("t", t)


func clear_shootay_meter():
	t = 0.0
	shootay_meter.material.set_shader_parameter("t", t)

# -- hardcoding for now
func shoot(shootay_val: ShootayGlobals.ShootayValues):
	if shootay_val == ShootayGlobals.ShootayValues.REFLECT:
		t -=0.33
	else:
		t += 0.33
	
	# -- floating point error premtive rounding
	t = snapped(t, 0.01)
	shootay_meter.material.set_shader_parameter("t", t)
