"Sets stop distance, this is really only useful for enemies whose stop distance is different from melee distance
Setting it up for hybrid enemies who can ranged and melee"
extends BTNode
class_name BTSetStopDistance

const BBKeys = preload("res://AI/BT/Common/BBKeys.gd")

@export var melee_distance: String = BBKeys.DESIRED_MELEE  
@export var scale: float = 1.0 # example. 0.9 to stop slightly inside

func tick(blackboard, _delta: float) -> int:
	var base := float(blackboard.get_value(melee_distance, 48.0))
	blackboard.set_value(BBKeys.STOP_DISTANCE, base * scale)
	return Status.SUCCESS
