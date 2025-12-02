extends Node2D

class_name Shootay

var shootay_value: ShootayGlobals.ShootayValues

var vel: Vector2 = Vector2.ZERO
var dist: float = 0.0
@export var MAX_DISTANCE: float = 10000
#@export var SHOOTING_SPEED: float = 600.0
@onready var ray = $RayCast2D

signal shootay_collided( pos: Vector2, normal: Vector2)
signal transmission_collided( shootay_A: Shootay, shootay_B: Shootay)
signal transmission_shot_wrapped( shootay: Shootay)
signal transmission_marked_collided( pos: Vector2 )
# --------------------------------------------------- shootay manager vars
var _id: int
var cam_ref: Camera2D # -- assigned when shot if shootay value is transmit
var player_ref: Player

var wrapping_bounds: Vector2
var wrapping_buffer: float


func _ready() -> void:
	ray.enabled = false 
	$MarkingTimer.timeout.connect( func(): 
		transmission_stack_count = 0)
	#assert(shootay_value)
	#if shootay_value == ShootayGlobals.ShootayValues.TRANSMIT:
	assert(cam_ref and player_ref)
	wrapping_bounds = cam_ref.get_viewport().size
	assert(wrapping_buffer)
	wrapping_bounds += Vector2(wrapping_buffer, wrapping_buffer)
	# -- there is a unique id given by manager to resolve who explodes
	# -- to prevent multiple explosions
	$Area2D.collided_with_shoootay.connect( shootay_collided_with_shoootay_fn )
	$Area2D.hitbox_area_entered.connect( on_hitbox_area_entered )
			
			
	$Area2D.collided_with_body.connect( func():
		ray.enabled = true)

func _physics_process(delta: float) -> void:
	var delta_pos = vel * delta
	dist += delta_pos.length()
	global_position += delta_pos
	if dist > MAX_DISTANCE:
		queue_free()
	else:
		if is_reflecting_shootay():
			reflect()
		else:
			wrap_viewport()


func wrap_viewport():
	var x = player_ref.global_position.x
	var y = player_ref.global_position.y
	
	var no_longer_active_for_teleport: bool = false
	if global_position.x > x + wrapping_bounds.x:
		global_position.x = x - wrapping_bounds.x
		no_longer_active_for_teleport = true
	elif global_position.x < x - wrapping_bounds.x:
		global_position.x = x + wrapping_bounds.x
		no_longer_active_for_teleport = true
	elif global_position.y > y + wrapping_bounds.y:
		global_position.y = y - wrapping_bounds.y
		no_longer_active_for_teleport = true
	elif global_position.y < y - wrapping_bounds.y:
		global_position.y = y + wrapping_bounds.y
		no_longer_active_for_teleport = true
	
	if no_longer_active_for_teleport and shootay_value == ShootayGlobals.ShootayValues.TRANSMIT:
		emit_signal("transmission_shot_wrapped", self)


func reflect():
	if ray.is_colliding():
		var n = ray.get_collision_normal()
		emit_signal("shootay_collided", ray.get_collision_point(), n)
		#if ray.get_collider() is Player:
			#queue_free()
		stretch_squash( false )
		vel = vel.bounce( n ) * 0.8
		rotation_from_velocity_vector( vel )
		ray.enabled = false


func shoot(_vel: Vector2, _shootay_val: ShootayGlobals.ShootayValues):
	#$AttackComponent.dir = dir
	$AttackComponent.parent = self # -- this is so I can get the direction its going
								   # -- not ideal
	$AttackComponent.dynamic_data["shootay_value"] = _shootay_val
	shootay_value = _shootay_val
	$ShootayColorComponent.set_shootay_visual( shootay_value )
	set_shootay_collision_layer()
	vel = _vel                
	rotation_from_velocity_vector( _vel )
	stretch_squash( true )
	GlobalSignals.emit_signal("shake_camera", {"type": "Shootay", "amount": 20, "dir": _vel})


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
	if _id > a_shootay._id:
		GlobalSignals.emit_signal("shootay_exploded", global_position)
	queue_free()


func shootay_collided_with_shoootay_fn( other: Shootay):
	if (other.shootay_value != shootay_value):
		explode( other )
	else:
		if (other.is_transmitting_shootay() and is_transmitting_shootay()):
			# -- teleport signal
			if _id > other._id:
				emit_signal( "transmission_collided", self, other)
			queue_free()
		if is_reflecting_shootay():
			ray.enabled = true


func is_reflecting_shootay() -> bool:
	return shootay_value == ShootayGlobals.ShootayValues.REFLECT


func is_transmitting_shootay() -> bool:
	return not is_reflecting_shootay()


var transmission_stack_count: int = 0
@export var num_transmissions_to_mark: int = 4

func on_hitbox_area_entered( hb: HitboxComponent ):
	# -- can we always assume that to have a hb, the parent will always be the
	# -- the objects root node?
	if hb.is_in_group("Enemy"):
		if is_transmitting_shootay():
			$MarkingTimer.start()
			# -- if the enemy is marked, teleport to him
			if hb.get_parent().is_marked():
				emit_signal("transmission_marked_collided", global_position)
				queue_free()
			# -- otherwise, increment the transmission collision count
			# -- and mark if enemy is the Nth one
			transmission_stack_count += 1
			
			if transmission_stack_count == num_transmissions_to_mark:
				transmission_stack_count = 0
				print( transmission_stack_count)
				hb.get_parent().mark_for_teleport()
