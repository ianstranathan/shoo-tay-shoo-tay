extends CharacterBody2D

class_name Player

# -- signals
signal died
signal boosted( pos: Vector2)
signal shot_a_shootay( pos: Vector2, dir: Vector2, shootay_value:ShootayGlobals.ShootayValues)
"""
Current Movement variables are stateful
(can be changed by environmentals, shots etc)
"""

@export var input_manager: InputManager

@export_category("Movement")
@export var SPEED: float = 300.0
@export var DECL = 3000.0 # -- should this be proportinoal to speed?
@export var BOOSTING_SPEED: float = 1200
@export var ACCL := 2000.0 # -- should this be proportinoal to speed?
@export var BOOSTING_ACCL: float = 8000

# -- movement state vars
@onready var current_speed = SPEED
@onready var current_accl = ACCL
@onready var current_decl = DECL

@export_category("Aiming")
@export var aiming_manager: Node2D
@export var player_sprite: Sprite2D
@export var look_ahead_dist = 100.0


@export_category("Shooting")
@export var MAX_SHOOT_SPEED: float = 800 # -- really this should account for min speed (e.g 750)
@export var MIN_SHOOT_SPEED: float = 200
# -- this is used to offset aiming reticle

@export_category("Misc")
@export var boost_timer: Timer

var can_shoot: bool # -- to prevent spamming


func _ready() -> void:
	assert(input_manager)
	
	# -------------------------------------------------- overload manager
	$OverloadManager.overloaded.connect( func(): pass)

	# -------------------------------------------------- charging manager
	$ChargeManager.input_manager = input_manager
	$ChargeManager.charge_released.connect( func(val: ShootayGlobals.ShootayValues,
												 fn: Callable):
		shoot_a_shootay( val )
		fn.call())
	$ChargeManager.finished_charging.connect( func(): pass)
	
	# -------------------------------------------------- aiming manager
	$AimingManager.aim_rotated.connect( func( r: float):
		global_rotation = r)
	aiming_manager.input_manager = input_manager
	aiming_manager.my_init()
	
	# -------------------------------------------------- No spam firing
	$ReloadTimer.timeout.connect( func(): can_shoot = true)
	
	boost_timer.timeout.connect( func():
		current_speed = SPEED
		current_accl = ACCL)
	# -------------------------------------------------- 
	$HitboxComponent.was_hit.connect( func( attack ):
		$HitTimer.start()
		#$PlayerSprite.material.set_shader_parameter("hit_time", )
		if attack.dynamic_data.has("shootay_value"):
			var _val = attack.dynamic_data.get("shootay_value")
			if _val == ShootayGlobals.ShootayValues.REFLECT:
				var _shootay = attack.parent
				boost(_shootay.vel)
		$HealthComponent.take_damge( attack.damage ))

	# --------------------------------------------------
	$HealthComponent.health_changed.connect( func(ratio: float): # ratio is normalized
		player_sprite.material.set_shader_parameter("dmg_scale", 1. - ratio))
	$HealthComponent.health_depeleted.connect( func(): emit_signal("died"))

	$TeleportContainer.teleport_anim_finished.connect( func():
		Utils.hit_stop(0.05, 0.3))


func _physics_process(delta: float) -> void:
	var move_dir = input_manager.movement_vector()
	# -- Hittimer visual
	if !$HitTimer.is_stopped():
		$PlayerSprite.material.set_shader_parameter("hit_time", Utils.normalized_timer($HitTimer))
	# ------------------------ Move
	
	# -- lock the direction of boost
	if !boost_timer.is_stopped():
		velocity = velocity.move_toward( boost_dir * current_speed,
										 current_accl * delta)
	else:
		if !move_dir.is_equal_approx( Vector2.ZERO ):
			# -- accl to target velocity
			velocity = velocity.move_toward(move_dir.normalized() * current_speed,
											current_accl * delta)
		else:
			# -- decl to stop
			velocity = velocity.move_toward(Vector2.ZERO,
											current_decl * delta)
	move_and_slide()


var boost_dir:= Vector2.ZERO

func boost(a_shootay_vel: Vector2):
	Utils.hit_stop(0.05, 0.3)
	$OverloadManager.fune_fune_switch()
	boost_dir = a_shootay_vel.normalized()
	boost_timer.start()
	var r = (a_shootay_vel.length() / MAX_SHOOT_SPEED)
	current_speed = BOOSTING_SPEED * r
	current_accl = BOOSTING_ACCL * r
	
	if r > 0.80:
		emit_signal("boosted", global_position) # -- the time to blur


func look_ahead_position() -> Vector2:
	return look_ahead_dist * $AimingManager.get_aim_dir()


func shoot_a_shootay(shootay_value:ShootayGlobals.ShootayValues):
	if can_shoot:
		var shootay_speed = MAX_SHOOT_SPEED * $ChargeManager.get_charge_ratio() + \
							MIN_SHOOT_SPEED
		can_shoot = false
		$OverloadManager.fune_fune_check( shootay_value )
		emit_signal("shot_a_shootay",
					global_position,
					$AimingManager.get_aim_dir() * shootay_speed,
					shootay_value)


func teleport(pos: Vector2):
	$OverloadManager.fune_fune_switch()
	$TeleportContainer.teleport()
	global_position = pos
