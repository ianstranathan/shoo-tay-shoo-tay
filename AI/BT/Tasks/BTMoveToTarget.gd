extends BTNode
class_name BTMoveToTarget

const BBKeys = preload("res://AI/BT/Common/BBKeys.gd")   
var nav: NavigationAgent2D = null

@export var repath_interval := 0.20  # how often we want to try getting a new path. make it feel like reaction time
@export var arrive_margin: float = 0.0 # extra cushion past stop distance to prevent endless stuttering

var _accum := 0.0

func tick(blackboard, delta: float) -> int:
	if nav == null:
		return Status.FAILURE

	var target: Node2D = blackboard.get_value(BBKeys.TARGET)
	if target == null:
		return Status.FAILURE

	var stop_dist: float = float(blackboard.get_value(BBKeys.STOP_DISTANCE, 220.0))
	var dist: float = float(blackboard.get_value(BBKeys.DISTANCE, INF))
	nav.target_desired_distance = stop_dist
	
	# Close enough
	if dist <= stop_dist + arrive_margin:
		return Status.SUCCESS

	#update agent target at a controlled rate
	_accum += delta
	if _accum >= repath_interval:
		_accum = 0.0
		var target_pos: Vector2 = blackboard.get_value(BBKeys.TARGET_POS, target.global_position)
		nav.target_position = target_pos

	return Status.RUNNING

func reset() -> void:
	_accum = 0.0
