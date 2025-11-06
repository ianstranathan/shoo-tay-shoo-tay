extends RefCounted
class_name BTNode

enum Status { SUCCESS, FAILURE, RUNNING }

func reset() -> void:
	pass

func tick(blackboard, delta: float) -> int:
	return Status.SUCCESS
