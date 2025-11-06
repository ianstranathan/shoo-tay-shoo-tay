"this just tries a melee attack should almost always be a success once we get to this point we've
already done all of our checks. this doesnt really care if we hit or not, just that we attacked"
extends BTNode
class_name BTMeleeAttack

var component: Node = null

func tick(_bb, _dt) -> int:
	if component == null:
		return Status.FAILURE
	if "attack" in component:
		return Status.SUCCESS if component.attack() else Status.FAILURE
	return Status.FAILURE
