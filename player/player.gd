extends CharacterBody2D

@export_category("Movement")
var move_dir: Vector2 = Vector2.ZERO
@export var SPEED: float = 200.0

@export_category("Aiming")
@export var aiming_sprite: Sprite2D
@export var shooting_line_scale: float = 3.0
@onready var tex_size :Vector2i = $Sprite2D.texture.get_size()


@onready var player_sprite_tex_size: Vector2i = $Sprite2D.texture.get_size()
# ------------------------------------

var _aim_dir: Vector2 = Vector2.RIGHT
var _last_aim_dir := _aim_dir

var shootay: PackedScene = preload("res://shootay/shootay.tscn")

enum ShootayValues{
	REFLECT,
	TRANSMIT
}

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



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot reflect"):
		pass#shoot_shootay(ShootayValues.REFLECT)


#func shoot_shootay(v:ShootayValues):
	#var shootay_scene = shootay.instantiate()
	#shootay_scene.
