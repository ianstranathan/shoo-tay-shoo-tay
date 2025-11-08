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
@export var aiming_sprite: Sprite2D
@export var player_sprite: Sprite2D
@export var shooting_line_scale: float = 3.0
@onready var aiming_sprite_size :Vector2i = aiming_sprite.texture.get_size()
@export var look_ahead_dist = 100.0
@export_range(1,20) var rotation_speed: float = 10

# -- this is used to offset aiming reticle
@onready var _player_tex_size: Vector2 = player_sprite.texture.get_size()


var _aim_dir: Vector2 = Vector2.RIGHT
var _last_aim_dir := _aim_dir
var can_shoot: bool # -- to prevent spamming

@export var boost_timer: Timer

func _ready() -> void:
	assert(aiming_sprite)
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

	# -- copy the hitbox_collision shape?
	
func aim_anim(aiming_dir_len: float):
	# -- translate the position of the aiming sprite
	# -- to agree with its scaling
	var _scale = shooting_line_scale * aiming_dir_len # [0, 3]
	# -- 
	# NOTE change magic number please
	aiming_sprite.position.x = lerp(55.0, 0.0, aiming_dir_len) + (_scale * aiming_sprite_size.x/2.0
																 + 0.05 * _player_tex_size.x * player_sprite.scale.x) 
	aiming_sprite.material.set_shader_parameter("_scale", aiming_dir_len)


func _process(delta: float) -> void:
	var r_stick_input = Input.get_vector("aim left", "aim right", "aim up", "aim down")
	move_dir = Input.get_vector("move left", "move right", "move up", "move down")
	if r_stick_input != Vector2.ZERO:
		_last_aim_dir = _aim_dir
		_aim_dir = r_stick_input
	aim_anim(r_stick_input.length())

	# -- overload visual
	# player_sprite.material.set_shader_parameter("t", Utils.normalized_timer($ShootayTimer))


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot reflect"):
		shoot_a_shootay(ShootayGlobals.ShootayValues.REFLECT)
	elif Input.is_action_just_pressed("shoot transmit"):
		shoot_a_shootay(ShootayGlobals.ShootayValues.TRANSMIT)
	
	# ---------------------------- Turn
	var dir = _last_aim_dir.normalized();
	var angle = Vector2.RIGHT.angle_to( dir )
	#angle = PI / 2.0 + angle
	global_rotation = lerp_angle(global_rotation,angle,rotation_speed * delta)

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
	return look_ahead_dist * _last_aim_dir.normalized()


func shoot_a_shootay(shootay_value:ShootayGlobals.ShootayValues):
	if can_shoot:
		#$MuzzleFlash.muzzle_flash(shootay_value)
		can_shoot = false
		#var dir: Vector2 = _last_aim_dir.normalized()
		var dir: Vector2 = _last_aim_dir
		emit_signal("shot_a_shootay",
					global_position,# + dir * _player_tex_size.x / 2.0,
					dir,
					shootay_value)


func teleport(pos: Vector2):
	$TeleportContainer.teleport()
	global_position = pos
