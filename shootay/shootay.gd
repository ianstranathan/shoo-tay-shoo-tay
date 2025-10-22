extends Node2D

class_name Shootay

var shootay_value: ShootayGlobals.ShootayValues

var vel: Vector2 = Vector2.ZERO
var dist: float = 0.0
@export var MAX_DISTANCE: float = 10000
@export var SHOOTING_SPEED: float = 600.0
@onready var ray = $RayCast2D

# -- NOTE
var explosion_id: int

# -- NOTE
var wrapping_bounds: Vector2

func _ready() -> void:
	var _b = ShootayGlobals.wrapping_buffer
	assert( wrapping_bounds )
	wrapping_bounds += Vector2(_b, _b)
	
	$Area2D.area_entered.connect( func(area: Area2D):
		var p = area.get_parent()
		if p is Shootay:
			explode( p ))


func _physics_process(delta: float) -> void:
	var delta_pos = vel * delta
	dist += delta_pos.length()
	global_position += delta_pos
	if dist > MAX_DISTANCE:
		queue_free()

	if ray.is_colliding():
		stretch_squash( false )
		vel = vel.bounce(ray.get_collision_normal())
		rotation_from_velocity_vector( vel )
	
	# -- Wrapping logic
	#if global_position.x > wrapping_bounds.x:
		#global_position.x = -wrapping_bounds.x
	#elif global_position.x < wrapping_bounds.x:
		#global_position.x = wrapping_bounds.x
	#elif global_position.y > wrapping_bounds.y:
		#global_position.y = -wrapping_bounds.y
	#elif global_position.y < wrapping_bounds.y:
		#global_position.y = wrapping_bounds.y


#func on_area_entered( area: Area2D ):
	#if area.get_parent() is Shootay and area.get_parent().shootay_value != shootay_value:
		#explode()


func shoot(dir: Vector2, _shootay_val: ShootayGlobals.ShootayValues):
	shootay_value = _shootay_val
	$ShootayColorComponent.set_shootay_visual( shootay_value )
	set_shootay_collision_layer()
	assert( is_equal_approx(dir.length(), 1.0)) # -- .normalized() should be in player to save a call
	vel = dir * SHOOTING_SPEED                  # -- but just in case
	rotation_from_velocity_vector( dir )
	stretch_squash( true )
	GlobalSignals.emit_signal("shake_camera", {"type": "Shootay", "amount": 20, "dir": dir})


func stretch_squash(stretch: bool) -> void:
	var tween = create_tween()
	if stretch:
		Utils.shader_float_tween(tween, $Sprite2D, "_st_sq", 3.0, 1.0, 0.5, Tween.EASE_OUT, Tween.TRANS_BACK)
	else:
		Utils.shader_float_tween(tween, $Sprite2D, "_st_sq", 3.0, 1.0, 0.12, Tween.EASE_IN, Tween.TRANS_EXPO)
		#tween.tween_callback( func():
			#var _tween = create_tween()
			#Utils.shader_float_tween(_tween, $Sprite2D, "_st_sq", 4.0, 1.0, 0.1, Tween.EASE_OUT, Tween.TRANS_EXPO))


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
	
#func resolve_raycast_collision(_collider: CollisionObject2D):
	# var _layer = _collider.collision_layer
	# -- if the shootay is a reflection shootay && the
	# -- coll object is a reflection object (color  and collision match the
	# -- shootay's, reflect, otherwise, transmit
	#if (shootay_value == ShootayGlobals.ShootayValues.REFLECT and
		#_layer == ShootayGlobals.reflection_layer):


func explode(shootay_collided_with: Shootay):
	if (shootay_collided_with.shootay_value != shootay_value):
		if explosion_id > shootay_collided_with.explosion_id:
			GlobalSignals.emit_signal("shootay_exploded", global_position)
		queue_free()
