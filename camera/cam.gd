extends Camera2D

@export var target: Player


func _ready() -> void:
	assert( target )


func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(target.global_position + target.look_ahead_position(), 5.)
