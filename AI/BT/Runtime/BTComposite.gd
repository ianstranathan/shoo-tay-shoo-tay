"This is a parent to both Selector and Sequence composites. This level might not be neccessary and could collapse
or down but for now this should work without much upkeep if any"

extends BTNode
class_name BTComposite

#build array of all sequences,tasks,ect.
var children: Array[BTNode] = []
var _index: int = 0

#function we can call from anywhere to add a child task to this composite
func add_child(node: BTNode) -> BTComposite:
	children.append(node)
	return self

func reset() -> void:
	_index = 0
	for c in children:
		c.reset()
