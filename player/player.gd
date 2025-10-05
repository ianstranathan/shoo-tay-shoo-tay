extends CharacterBody2D

class_name Player

@export_category("Movement")
var move_dir: Vector2 = Vector2.ZERO
@export var SPEED: float = 200.0

@export_category("Aiming")
@export var aiming_sprite: Sprite2D
@export var shooting_line_scale: float = 3.0
@onready var tex_size :Vector2i = $Sprite2D.texture.get_size()
@export var look_ahead_dist = 100.0

# ------------------------------------
@onready var _player_tex_size: Vector2 = $Sprite2D2.texture.get_size()

var _aim_dir: Vector2 = Vector2.RIGHT
var _last_aim_dir := _aim_dir

var shootay_scene: PackedScene = preload("res://shootay/shootay.tscn")


func _ready() -> void:
	assert(aiming_sprite)
	pass
	#$OverchargeTimer.timeout.connect(     func(): is_flashing(true) )
	#$DamageFlashingTimer.timeout.connect( func(): is_flashing(false) )


func aim_anim(aiming_dir_len: float):
	# -- translate the position of the aiming sprite
	# -- to agree with its scaling
	var _scale = shooting_line_scale * aiming_dir_len # [0, 3]
	# -- 
	# lerp(55.0, 0.0, aiming_dir_len)
	aiming_sprite.position.x = lerp(55.0, 0.0, aiming_dir_len) + _scale * tex_size.x/2.0
	aiming_sprite.material.set_shader_parameter("_scale", aiming_dir_len)


func _process(delta: float) -> void:
	var r_stick_input = Input.get_vector("aim left", "aim right", "aim up", "aim down")
	move_dir = Input.get_vector("move left", "move right", "move up", "move down")
	if r_stick_input != Vector2.ZERO:
		_last_aim_dir = _aim_dir
		_aim_dir = r_stick_input
	aim_anim(r_stick_input.length())


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot reflect"):
		shoot_shootay(ShootayGlobals.ShootayValues.REFLECT)
	elif Input.is_action_just_pressed("shoot transmit"):
		shoot_shootay(ShootayGlobals.ShootayValues.TRANSMIT)
	
	# ---------------------------- Turn
	var dir = _last_aim_dir.normalized();
	var angle = Vector2.RIGHT.angle_to( dir )
	#angle = PI / 2.0 + angle
	global_rotation = angle

	# ------------------------ Move
	velocity = move_dir.normalized() * SPEED
	move_and_slide()
	
func is_flashing(b: bool) -> void:
	$Sprite2D.material.set_shader_parameter("is_flashing", 1.0 if b else 0.0)


func look_ahead_position() -> Vector2:
	return look_ahead_dist * _last_aim_dir.normalized()


func shoot_shootay(shootay_value:ShootayGlobals.ShootayValues):
	var shootay = shootay_scene.instantiate()
	get_tree().root.add_child(shootay)
	# -- offset it past the player
	shootay.global_position = (global_position + 
							   _last_aim_dir.normalized() * _player_tex_size.x / 2.0)
	# -- shoot
	shootay.shoot(_last_aim_dir, shootay_value)
