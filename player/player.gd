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
var move_dir: Vector2 = Vector2.ZERO
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
@export var MIN_SHOOT_SPEED: float = 50
# -- this is used to offset aiming reticle

@export_category("Misc")
@export var boost_timer: Timer

var can_shoot: bool # -- to prevent spamming
var charge_shot_speed_ratio: float = 0.0


func _ready() -> void:
	assert(input_manager)
	
	$AimingManager.aim_rotated.connect( func( r: float):
		global_rotation = r)
	# --------------------------------------------------
	$ShootayChargeTimer.timeout.connect( func():
		charge_shot_speed_ratio = 1.0)
	# --------------------------------------------------
	aiming_manager.input_manager = input_manager
	aiming_manager.my_init()
	# --------------------------------------------------
	
	$ReloadTimer.timeout.connect( func(): can_shoot = true)
	
	boost_timer.timeout.connect( func():
		boost_end_callback.call())
	# -------------------------------------------------- 
	$HitboxComponent.was_hit.connect( func( attack ):
		$HitTimer.start()
		#$PlayerSprite.material.set_shader_parameter("hit_time", )
		if attack.dynamic_data.has("shootay_value"):
			var _val = attack.dynamic_data.get("shootay_value")
			if _val == ShootayGlobals.ShootayValues.REFLECT:
				boost(attack.parent.vel)
		$HealthComponent.take_damge( attack.damage ))

	# --------------------------------------------------
	$HealthComponent.health_changed.connect( func(ratio: float): # ratio is normalized
		player_sprite.material.set_shader_parameter("dmg_scale", 1. - ratio))
	$HealthComponent.health_depeleted.connect( func(): emit_signal("died"))

	$TeleportContainer.teleport_anim_finished.connect( func():
		Utils.hit_stop(0.05, 0.3))


func _process(delta: float) -> void:
	move_dir = input_manager.movement_vector()


func _physics_process(delta: float) -> void:
	# ---------------------------- shoot & charge
	if !$ShootayChargeTimer.is_stopped():
		var _ratio = 1. - ($ShootayChargeTimer.time_left / $ShootayChargeTimer.wait_time)
		charge_shot_speed_ratio = _ratio
		$ShootayCharge.charge_up(_ratio)
	charge_shootay()
	
	# ---------------------------- Turn
	
	# -- Hittimer visual
	if !$HitTimer.is_stopped():
		$PlayerSprite.material.set_shader_parameter("hit_time", Utils.normalized_timer($HitTimer))
	# ------------------------ Move
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

# I wish I could make a simple closure around these guys, but whatever
var pre_boost_speed: float
var pre_boost_accl: float
func boost(_dir: Vector2):
	# if the closure speed, accl isn't the boost ones
	pre_boost_speed = current_speed
	pre_boost_accl = current_accl
	Utils.hit_stop(0.05, 0.3)
	emit_signal("boosted", global_position) # -- the time to blur
	# $BoostContainer.set_trail_active(true)
	# _dir comes from the reflecting bullets vector
	boost_dir = _dir.normalized()
	boost_timer.start()
	# -- change the accl_curve
	current_speed = BOOSTING_SPEED
	current_accl = BOOSTING_ACCL


# -- TODO
# -- put this edge case into the boost function and make tidier
func boost_end_callback():
	# -- there's an edge case where you can get hit before this is reinitialized
	# -- so the last movement vars (pre_boost vars) were actually the boosted ones
	if (pre_boost_accl == BOOSTING_ACCL or
		pre_boost_speed == BOOSTING_SPEED):
		current_speed = SPEED
		current_accl = ACCL
	else:
		current_speed = pre_boost_speed
		current_accl = pre_boost_accl
	
	#$BoostContainer.set_trail_active(false)


func look_ahead_position() -> Vector2:
	return look_ahead_dist * $AimingManager.get_aim_dir()


func shoot_a_shootay(shootay_value:ShootayGlobals.ShootayValues):
	if can_shoot:
		var shootay_speed = MAX_SHOOT_SPEED * charge_shot_speed_ratio + \
							MIN_SHOOT_SPEED
		can_shoot = false
		charge_shot_speed_ratio = 0.0
		emit_signal("shot_a_shootay",
					global_position,
					$AimingManager.get_aim_dir() * shootay_speed,
					shootay_value)
		

func teleport(pos: Vector2):
	$TeleportContainer.teleport()
	global_position = pos


var is_charging: bool = false
func charge_shootay():
	var is_any_shoot_action_held = input_manager.pressed_action("shoot reflect") or \
								   input_manager.pressed_action("shoot transmit")
	if is_any_shoot_action_held and !is_charging:
		is_charging = true
		# -- timer to make visual or sound proportional to
		$ShootayChargeTimer.start()
		# -- start charge particles
		$ShootayCharge.start_charging(shootay_val_from_action_name( 
			input_manager.get_last_pressed_action()))
		
	elif !is_any_shoot_action_held and is_charging:
		is_charging = false
		shoot_a_shootay(  shootay_val_from_action_name( input_manager.get_last_pressed_action()))


func shootay_val_from_action_name( val: StringName) -> ShootayGlobals.ShootayValues:
	$ShootayCharge.stop_charging()
	if val == "shoot reflect":
		return ShootayGlobals.ShootayValues.REFLECT
	else:
		return ShootayGlobals.ShootayValues.TRANSMIT
