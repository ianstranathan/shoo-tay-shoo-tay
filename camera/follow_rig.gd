extends Node2D

@export_category("Follow Target")
@export var target: Player
@export_category("Camera Smoothing")
@export_range(0.1, 40.0) var smooth_speed := 8.0 # smooth "speed" to avoid the inversion

var _target_pos: Vector2

func _ready() -> void:
	assert(target)
	_target_pos = global_position
	
func _physics_process(delta: float) -> void:
	var _desired_pos := target.global_position + target.look_ahead_position()
	# Exponential, frame rate independent smoothing, seems like this might be more robust than previous solution.
	var alpha := 1.0 - exp(-smooth_speed * delta)
	_target_pos = _target_pos.lerp(_desired_pos, alpha)
	
	global_position = _target_pos.round()# ignore fractional values
