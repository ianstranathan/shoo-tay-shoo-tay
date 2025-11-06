"Selector Class will try leafs in sequence until it finds one it can succeed. On success it will restart
for example we tried a melee attack and failed, so we tried a range attack and succeeded. now we try melee again
and so on. If it fails everything the selector fails and goes back to top node and gives us the option to idle 
or patrol ect.."

extends BTComposite
class_name BTSelector

#try the first child in array if it fails move to the next
func tick(blackboard, delta: float) -> int:
	var i := _index
	while i < children.size():
		var st := children[i].tick(blackboard, delta)
		match st:
			Status.SUCCESS:
				_index = 0 #reset index on success. always scanning left to right
				return Status.SUCCESS
			Status.RUNNING:
				_index = i #keep running until it succeeds or fails
				return Status.RUNNING
			Status.FAILURE:
				i += 1 #if it fails try the next
				continue
	_index = 0
	return Status.FAILURE #if every child fails the selector fails too
