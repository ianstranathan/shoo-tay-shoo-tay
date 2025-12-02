extends CharacterBody2D

class_name Player

# -- signals
signal died
signal overloaded
signal boosted( pos: Vector2)
signal shot_a_shootay( pos: Vector2, dir: Vector2, shootay_value:ShootayGlobals.ShootayValues)
signal overload_cleared()
signal started_dashing( _self:CharacterBody2D, dir: Vector2, speed: float, timer: Timer)
signal stopped_dashing( )
"""
Current Movement variables are stateful
(can be changed by environmentals, shots etc)
"""

@export var input_manager: InputManager

@export_category("Movement")
@export var SPEED: float = 300.0
@export var DECL = 4000.0 # -- should this be proportinoal to speed?
@export var ACCL := 2000.0 # -- should this be proportinoal to speed?
@export var BOOSTING_SPEED: float = 1200
@export var BOOSTING_ACCL: float = 8000
@export var BOOSTING_DECL: float = 10000
@export var DASHING_SPEED: float = 1500
@export var DASHING_ACCL: float = 8000
@export var DASHING_DECL: float = 16000

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

enum MovementStates{
	REGULAR,
	DASHING,
	SLIPSTREAMING,
	GRINDING,
	BOOSTING,
	TELEPORTING,
}

# -- the enum of the state is now also its priority
# -- so, e.g. Boosting overrides grinding and dashing
# -- this is pointless right now, bcz I just copies the enum, but
# -- you can move this around now
const MOVEMENT_STATE_PRIORIOTY_ARR = [ 
	MovementStates.REGULAR,
	MovementStates.DASHING,
	MovementStates.SLIPSTREAMING,
	MovementStates.GRINDING,
	MovementStates.BOOSTING,
	MovementStates.TELEPORTING]

var movement_state: MovementStates = MovementStates.REGULAR
var prev_movement_state: MovementStates = movement_state


var saved_masks_array: Array[int] = []

func _ready() -> void:
	assert(input_manager)
	# -------------------------------------------------- 
	Utils.get_used_collision_mask_layers($HitboxComponent, saved_masks_array, 10)
	# -------------------------------------------------- 
	#$PlayerDashEffect.set_dash_speed( DASHING_SPEED )
	$DashTimer.timeout.connect( func():
		vel_fn = vel_fn_closure( Vector2.ZERO, 0.0, DASHING_DECL))
	
	# -------------------------------------------------- overload manager
	$OverloadManager.overloaded.connect( func():
		emit_signal("overloaded"))

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
		vel_fn = vel_fn_closure( Vector2.ZERO, 0.0, BOOSTING_DECL))

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
		Utils.hit_stop(0.05, 0.2))


func _physics_process(delta: float) -> void:
	if input_manager.just_pressed_action( "dash"):
		movement_state_transition(MovementStates.DASHING)
	# -- Hittimer visual -- refactor with a modulate canvas item call I think
	if !$HitTimer.is_stopped():
		$PlayerSprite.material.set_shader_parameter("hit_time", Utils.normalized_timer($HitTimer))
	# ------------------------ Move
	var move_dir = input_manager.movement_vector()
	match movement_state:
		MovementStates.REGULAR:
			if !move_dir.is_equal_approx( Vector2.ZERO ):
			# -- accl to target velocity
				velocity = velocity.move_toward(move_dir.normalized() * current_speed,
												current_accl * delta)
			else:
				# -- decl to stop
				velocity = velocity.move_toward(Vector2.ZERO,
												current_decl * delta)
		MovementStates.BOOSTING, MovementStates.DASHING:
			vel_fn.call(delta)
			if velocity.is_equal_approx(Vector2.ZERO):
				movement_state_transition( MovementStates.REGULAR )

	move_and_slide()


var boost_dir:= Vector2.ZERO

func boost(a_shootay_vel: Vector2):
	movement_state_transition(MovementStates.BOOSTING)
	emit_signal("overload_cleared")
	Utils.hit_stop(0.05, 0.3)
	$OverloadManager.clear_overload()
	boost_dir = a_shootay_vel.normalized()
	boost_timer.start()
	var r = (a_shootay_vel.length() / MAX_SHOOT_SPEED)
	vel_fn = vel_fn_closure(a_shootay_vel,
							BOOSTING_SPEED * r,
							BOOSTING_ACCL * r)
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
	$OverloadManager.clear_overload()
	emit_signal("overload_cleared")
	#$Melee.do_melee()
	$TeleportContainer.teleport()
	global_position = pos


var dash_dir: Vector2 = Vector2.ZERO
func dash():
	$DashTimer.start()
	# -- make player invulnerable
	$HitboxComponent.make_invulnerable( true )
	# -- 
	dash_dir = input_manager.movement_vector()
	# -- slow down for emphasis
	Utils.hit_stop(0.06, 0.2)
	
	# -- change kinematics
	vel_fn = vel_fn_closure(input_manager.movement_vector(), DASHING_SPEED, DASHING_ACCL)

	# -- do vfx
	emit_signal("started_dashing", self, dash_dir, DASHING_SPEED, $DashTimer)

	# -- 

func return_to_normal_movement():
	current_speed = SPEED
	current_accl = ACCL


var vel_fn: Callable;
func vel_fn_closure(_dir: Vector2, _speed: float, _accl: float):
	return func(delta: float):
		velocity = velocity.move_toward( _dir * _speed,
										_accl * delta)
		#move_and_slide()

func movement_state_transition(new_movement_state: MovementStates):
	if movement_state != new_movement_state:
		match movement_state:
			MovementStates.REGULAR:
				match new_movement_state:
					MovementStates.DASHING:
						dash()
					# gotta make a closure around something
					#MovementStates.BOOSTING:
						#
			MovementStates.DASHING:
				if new_movement_state == MovementStates.REGULAR:
					emit_signal("stopped_dashing")
					$HitboxComponent.make_invulnerable( false )
					return_to_normal_movement()
			MovementStates.SLIPSTREAMING:
				pass
			MovementStates.GRINDING:
				pass
			MovementStates.BOOSTING:
				if new_movement_state == MovementStates.REGULAR:
					return_to_normal_movement()
			MovementStates.TELEPORTING:
				pass
		# ----------------------------------
		prev_movement_state = movement_state
		movement_state = new_movement_state
		# ----------------------------------


func restart():
	# -- FIXME / FORMALIZEME
	$PlayerSprite.material.set_shader_parameter("dmg_scale", 0.)
	$PlayerSprite.material.set_shader_parameter("t", 0.)
	$HealthComponent.restore_full_health()
	$OverloadManager.clear_overload()
	global_position = Vector2.ZERO
