"cooldown decorator we can use to limit number of attacks"
extends BTDecorator
class_name BTCooldown

@export var cooldown_time := 0.6
var _timer := 0.0

func tick(bb, delta) -> int:
	if _timer > 0.0:
		_timer = max(0.0, _timer - delta) 
		return Status.FAILURE #prevents tree from going past this point as long as the timer is still ticking
	if child == null:
		return Status.FAILURE
	var status := child.tick(bb, delta) #if no cooldown let child run
	if status == Status.SUCCESS: #if child succeeded action set timer to cooldown time
		_timer = cooldown_time #reset timer
	return status

func reset() -> void:
	_timer = 0.0
	
