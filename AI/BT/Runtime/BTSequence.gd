#______________________________________________________
#Sequence class is execute all leafs in order. if any of the actions fails it restarts the sequence.
#______________________________________________________
extends BTComposite
class_name BTSequence

func tick(blackboard, delta: float) -> int:
	var i := _index
	while i < children.size():
		var st := children[i].tick(blackboard, delta)
		match st:
			Status.SUCCESS:
				i += 1
				continue
			Status.RUNNING:
				_index = i
				return Status.RUNNING
			Status.FAILURE:
				_index = 0
				return Status.FAILURE
	_index = 0
	return Status.SUCCESS
