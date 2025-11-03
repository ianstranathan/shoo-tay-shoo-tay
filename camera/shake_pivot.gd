extends Node2D

var shootay_easing_fn = null
@onready var shoot_timer: Timer = $ShootShakeTimer

func _ready() -> void:
	GlobalSignals.shake_camera.connect(shake)
	$ShootShakeTimer.timeout.connect(func(): shootay_easing_fn = null)

func _physics_process(delta: float) -> void:
	var offset := Vector2.ZERO

	if !shoot_timer.is_stopped():
		var t: float = Utils.normalized_timer($ShootShakeTimer)
		offset = shootay_easing_fn.call(t)
	else:
		# Smoothly return to zero when shake ends
		offset = position.lerp(Vector2.ZERO, 10.0 * delta)

	#Apply the offset locally. The Camera2D inherits FollowRig + this offset. 
	#This might have affected exactly how the shake looks, might need tweaking.
	position = offset.round()

func shake(data: Dictionary):
	match data.type:
		"Shootay":
			shootay_easing_fn = func(t): return data.amount * inverted_parabola(t) * data.dir.normalized()
			shoot_timer.start()
			
# -- this is just something extemporaneously cooked up, can be whatever
func inverted_parabola(t: float):
	assert(t <= 1 and t >= 0)
	return -(3. * t - 1.)*(3. * t - 1.) + 1
