extends Node2D

class_name Shootay

var shootay_value: ShootayGlobals.ShootayValues

var vel: Vector2 = Vector2.ZERO
var dist: float = 0.0
@export var MAX_DISTANCE: float = 10000
@export var SHOOTING_SPEED: float = 600.0
@onready var ray = $RayCast2D

signal shootay_collided( pos: Vector2, normal: Vector2)
signal transmission_collided( midpoint: Vector2)


# -- NOTE shootay manager
var explosion_id: int
var cam_ref: Camera2D # -- assigned when shot if shootay value is transmit
var player_ref: Player

var wrapping_bounds: Vector2
var wrapping_buffer: float

func _ready() -> void:
	#assert(shootay_value)
	#if shootay_value == ShootayGlobals.ShootayValues.TRANSMIT:
	assert(cam_ref and player_ref)
	wrapping_bounds = cam_ref.get_viewport().size
	assert(wrapping_buffer)
	wrapping_bounds += Vector2(wrapping_buffer, wrapping_buffer)
	# -- there is a unique id given by manager to resolve who explodes
	# -- to prevent multiple explosions
	$Area2D.shootay_collided_with_shoootay.connect( shootay_collided_with_shoootay_fn )
	

func _physics_process(delta: float) -> void:
	var delta_pos = vel * delta
	dist += delta_pos.length()
	global_position += delta_pos
	if dist > MAX_DISTANCE:
		queue_free()

	if ray.is_colliding() and is_reflecting_shootay():
		reflect()

	if is_transmitting_shootay():
		wrap_viewport()

func wrap_viewport():
	var x = player_ref.global_position.x
	var y = player_ref.global_position.y
	
	if global_position.x > x + wrapping_bounds.x:
		global_position.x = x - wrapping_bounds.x
	elif global_position.x < x - wrapping_bounds.x:
		global_position.x = x + wrapping_bounds.x
	elif global_position.y > y + wrapping_bounds.y:
		global_position.y = y - wrapping_bounds.y
	elif global_position.y < y - wrapping_bounds.y:
		global_position.y = y + wrapping_bounds.y

func reflect():
	var n = ray.get_collision_normal()
	emit_signal("shootay_collided", ray.get_collision_point(), n)
	#if ray.get_collider() is Player:
		#queue_free()
	stretch_squash( false )
	vel = vel.bounce( n )
	rotation_from_velocity_vector( vel )

func shoot(dir: Vector2, _shootay_val: ShootayGlobals.ShootayValues):
	#$AttackComponent.dir = dir
	$AttackComponent.parent = self # -- this is so I can get the direction its going
								   # -- not ideal
	$AttackComponent.dynamic_data["shootay_value"] = _shootay_val
	shootay_value = _shootay_val
	$ShootayColorComponent.set_shootay_visual( shootay_value )
	set_shootay_collision_layer()
	
	# -- check to make sure we're not normalizing  multiple times
	# -- everything really needs to be normalized, so origin point should be
	# -- responsible
	# -- assert is here just in case, doesn't exist in non-debug build
	assert( is_equal_approx(dir.length(), 1.0)) 
	vel = dir * SHOOTING_SPEED                  
	rotation_from_velocity_vector( dir )
	stretch_squash( true )
	GlobalSignals.emit_signal("shake_camera", {"type": "Shootay", "amount": 20, "dir": dir})


func stretch_squash(stretch: bool) -> void:
	var tween = create_tween()
	if stretch:
		Utils.shader_float_tween(tween, $Sprite2D, "_st_sq", 3.0, 1.0, 0.5, Tween.EASE_OUT, Tween.TRANS_BACK)
	else:
		Utils.shader_float_tween(tween, $Sprite2D, "_st_sq", 3.0, 1.0, 0.12, Tween.EASE_IN, Tween.TRANS_EXPO)


func rotation_from_velocity_vector(dir: Vector2):
	var angle = Vector2.RIGHT.angle_to( dir )
	global_rotation = angle


func set_shootay_collision_layer():
	var _layer_to_turn_on: ShootayGlobals.ShootayValues
	var _layer_to_turn_off: ShootayGlobals.ShootayValues
	
	if shootay_value == ShootayGlobals.ShootayValues.REFLECT:
		_layer_to_turn_on = ShootayGlobals.reflection_layer
		_layer_to_turn_off = ShootayGlobals.transmission_layer
	else:
		_layer_to_turn_on = ShootayGlobals.transmission_layer
		_layer_to_turn_off = ShootayGlobals.reflection_layer
		
	$Area2D.set_collision_layer_value(_layer_to_turn_on, true)
	$Area2D.set_collision_layer_value(_layer_to_turn_off, false)
	ray.set_collision_mask_value(_layer_to_turn_on, true)
	ray.set_collision_mask_value(_layer_to_turn_off, false)


func explode(a_shootay: Shootay):
	if explosion_id > a_shootay.explosion_id:
		GlobalSignals.emit_signal("shootay_exploded", global_position)
	queue_free()


func shootay_collided_with_shoootay_fn( other: Shootay):
	if (other.shootay_value != shootay_value):
		explode( other )
	else:
		if other.is_transmitting_shootay() and is_transmitting_shootay():
			# -- teleport signal
			if explosion_id > other.explosion_id:
				emit_signal( "transmission_collided", (global_position - other.global_position) / 2.0 )
			queue_free()

func is_reflecting_shootay() -> bool:
	return shootay_value == ShootayGlobals.ShootayValues.REFLECT


func is_transmitting_shootay() -> bool:
	return not is_reflecting_shootay()
