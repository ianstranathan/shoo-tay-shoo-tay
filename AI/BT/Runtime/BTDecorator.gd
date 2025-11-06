#Helper function to single out a particular child, will be used for functions like invertor
extends BTNode
class_name BTDecorator

var child: BTNode = null

func set_child(node: BTNode) -> BTDecorator:
	child = node
	return self

func reset() -> void:
	if child:
		child.reset()
