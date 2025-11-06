"quick task to check if agent is within some distance"
extends BTNode
class_name BTDistanceWithin

const BBKeys = preload("res://AI/BT/Common/BBKeys.gd")

@export var key_distance: String = BBKeys.DESIRED_MELEE #defaulting to melee for now but this can be set in code
@export var margin: float = 0.0 #allowing some margin so enemies can think theyll hit then miss just a little bit

func tick(blackboard, _delta: float) -> int:
	var distance  := float(blackboard.get_value(BBKeys.DISTANCE, INF)) #distance from target
	var y := float(blackboard.get_value(key_distance, 48.0)) + margin #desired distance + margin
	return Status.SUCCESS if distance <= y else Status.FAILURE #are we there yet?
