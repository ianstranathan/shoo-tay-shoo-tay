extends CharacterBody2D

class_name Player

@export var base_col: Color = Color(0.4, 0.6, 0.8, 1.0)

@export_category("Movement")
var move_dir: Vector2 = Vector2.ZERO
@export var SPEED: float = 200.0

@export_category("Aiming")
@export var aiming_sprite: Sprite2D
@export var player_sprite: Sprite2D
@export var shooting_line_scale: float = 3.0
@onready var aiming_sprite_size :Vector2i = aiming_sprite.texture.get_size()
@export var look_ahead_dist = 100.0

# -- Shootay-Shootay
@onready var shootay_timer: Timer = $ShootayTimer

# -- this is used to offset aiming reticle
@onready var _player_tex_size: Vector2 = player_sprite.texture.get_size()

var shootay_manager: Node2D
var _aim_dir: Vector2 = Vector2.RIGHT
var _last_aim_dir := _aim_dir

func _ready() -> void:
	player_sprite.material.set_shader_parameter("src_col", base_col)
	assert(aiming_sprite)
	shootay_timer.timeout.connect( shootay_shootay )

func aim_anim(aiming_dir_len: float):
	# -- translate the position of the aiming sprite
	# -- to agree with its scaling
	var _scale = shooting_line_scale * aiming_dir_len # [0, 3]
	# -- 
	# lerp(55.0, 0.0, aiming_dir_len)
	aiming_sprite.position.x = lerp(55.0, 0.0, aiming_dir_len) + _scale * aiming_sprite_size.x/2.0
	aiming_sprite.material.set_shader_parameter("_scale", aiming_dir_len)


func _process(delta: float) -> void:
	var r_stick_input = Input.get_vector("aim left", "aim right", "aim up", "aim down")
	move_dir = Input.get_vector("move left", "move right", "move up", "move down")
	if r_stick_input != Vector2.ZERO:
		_last_aim_dir = _aim_dir
		_aim_dir = r_stick_input
	aim_anim(r_stick_input.length())


func _physics_process(delta: float) -> void:
	shootay_shootay_visual()
	
	if Input.is_action_just_pressed("shoot reflect"):
		shoot_a_shootay(ShootayGlobals.ShootayValues.REFLECT)
	elif Input.is_action_just_pressed("shoot transmit"):
		shoot_a_shootay(ShootayGlobals.ShootayValues.TRANSMIT)
	
	# ---------------------------- Turn
	var dir = _last_aim_dir.normalized();
	var angle = Vector2.RIGHT.angle_to( dir )
	#angle = PI / 2.0 + angle
	global_rotation = angle

	# ------------------------ Move
	velocity = move_dir.normalized() * SPEED
	move_and_slide()


func look_ahead_position() -> Vector2:
	return look_ahead_dist * _last_aim_dir.normalized()


func shoot_a_shootay(shootay_value:ShootayGlobals.ShootayValues):
	assert(shootay_manager)
	var dir: Vector2 = _last_aim_dir.normalized()
	shootay_manager.make_shootay(global_position +  dir * _player_tex_size.x / 2.0,
								 dir,
								 shootay_value)
	# -- shoot
	#shootay.shoot(, shootay_value)


func shootay_shootay_visual():
	pass
	#if !shootay_timer.is_stopped():
		#$Sprite2D2.material.set_shader_paremeter("src_col", 
		#Utils.normalized_timer(shootay_timer)
		
func shootay_shootay():
	pass
