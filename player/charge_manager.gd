extends Node2D

signal finished_charging()
signal charge_released( val: StringName, fn: Callable )

var input_manager: InputManager
var is_charging: bool = false
var charge_shot_speed_ratio = 0.0

func _ready() -> void:
	$ShootayChargeTimer.timeout.connect( func():
		charge_shot_speed_ratio = 1.0
		emit_signal("finished_charging"))


func _physics_process(delta: float) -> void:
	if !$ShootayChargeTimer.is_stopped():
		var _ratio = 1. - ($ShootayChargeTimer.time_left / $ShootayChargeTimer.wait_time)
		charge_shot_speed_ratio = _ratio
		$ShootayCharge.charge_up(_ratio)


func _input(_event: InputEvent) -> void:
	charge_shootay()


func charge_shootay() -> void:
	assert(input_manager)
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
		$ShootayCharge.stop_charging()
		emit_signal("charge_released",
					shootay_val_from_action_name( input_manager.get_last_pressed_action()),
					func(): charge_shot_speed_ratio = 0.0)


func shootay_val_from_action_name( val: StringName) -> ShootayGlobals.ShootayValues:
	if val == "shoot reflect":
		return ShootayGlobals.ShootayValues.REFLECT
	else:
		return ShootayGlobals.ShootayValues.TRANSMIT


func get_charge_ratio():
	return charge_shot_speed_ratio
	
