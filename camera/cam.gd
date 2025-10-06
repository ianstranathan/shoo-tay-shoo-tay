extends Camera2D

@export var target: Player

@onready var _target_pos: Vector2 = target.global_position

var shootay_easing_fn = null

func _ready() -> void:
	assert( target )
	GlobalSignals.shake_camera.connect( shake )
	
	$ShootShakeTimer.timeout.connect(func(): shootay_easing_fn =null)

func _physics_process(delta: float) -> void:
	_target_pos = target.global_position
	if !$ShootShakeTimer.is_stopped():
		var t = Utils.normalized_timer($ShootShakeTimer)
		_target_pos += shootay_easing_fn.call(t)

	global_position = global_position.move_toward(_target_pos + target.look_ahead_position(), 5.)
	

func shake(data: Dictionary):
	match data.type:
		"Shootay":
			shootay_easing_fn = func(t): return data.amount * inverted_parabola(t) * data.dir.normalized()
			$ShootShakeTimer.start()


# -- this is just something extemporaneously cooked up, can be whatever
func inverted_parabola(t: float):
	assert(t <= 1 and t >= 0)
	return -(3. * t - 1.)*(3. * t - 1.) + 1.
