"Look at target, this is really quick and dirty. We could add some delay and some variance so it doesnt look so
robotic but lets get it moving"
extends BTNode
class_name BTFaceTarget

const BBKeys = preload("res://AI/BT/Common/BBKeys.gd")

var actor: Node2D = null

func tick(bb, _delta):
	if actor == null:
		return Status.FAILURE

	var target: Node2D = bb.get_value(BBKeys.TARGET)
	if target == null:
		return Status.FAILURE

	actor.look_at(target.global_position)
	return Status.SUCCESS
