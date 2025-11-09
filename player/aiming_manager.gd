extends Node2D

@export_category("Controller Aiming Visual")
@export var shooting_line_scale: float = 3.0
@export var controller_aiming_sprite: Sprite2D
@onready var controller_aiming_sprite_size :Vector2i = controller_aiming_sprite.texture.get_size()

@export_category("Mouse Aiming Visual")
@export var mouse_aiming_sprite: Sprite2D


var input_manager: InputManager
var is_using_controller: bool = true
var dir: Vector2

func _ready() -> void:
	assert(mouse_aiming_sprite)
	assert(controller_aiming_sprite)
	

func aim_anim():
	if is_using_controller:
		dir = input_manager.aiming_vector()
		controller_aim_anim()
	else:
		dir = input_manager.aiming_vector( global_position )
		mouse_aiming_sprite.position.x = dir.length()


func controller_aim_anim():
	var aiming_dir_len = dir.length()
	# -- translate the position of the aiming sprite
	# -- to agree with its scaling
	var _scale = shooting_line_scale * aiming_dir_len # [0, 3]
	# NOTE change magic number please
	controller_aiming_sprite.position.x = lerp(55.0, 0.0, aiming_dir_len) + (_scale * controller_aiming_sprite_size.x/2.0)
																 #+ 0.05 * _player_tex_size.x * player_sprite.scale.x) 
	controller_aiming_sprite.material.set_shader_parameter("_scale", aiming_dir_len)


func _process(delta: float) -> void:
	aim_anim()


func my_init():
	is_using_controller = input_manager.is_using_controller()
	input_manager.input_source_type_changed.connect( func(input_source_enum):
		is_using_controller = (true if 
							   input_source_enum == input_manager.InputSourceType.CONTROLLER 
							   else false)
		if is_using_controller:
			$ControllerAimingSprite.visible = true
			$MouseAimingSprite.visible = false
		else:
			$ControllerAimingSprite.visible = false
			$MouseAimingSprite.visible = true)
