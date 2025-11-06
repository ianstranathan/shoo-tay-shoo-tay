
"This class brings this all together and connects the black board and behavior tree for whatever
agent its attached to. This also contains the core update call running the ai system."

extends RefCounted
class_name BTRunner

var root: BTNode
var blackboard

func set_tree(root_node: BTNode, bb) -> void:
	root = root_node
	blackboard = bb

func tick(delta: float) -> int:
	if root == null or blackboard == null:
		return BTNode.Status.FAILURE
	return root.tick(blackboard, delta)

func reset() -> void:
	if root:
		root.reset()
