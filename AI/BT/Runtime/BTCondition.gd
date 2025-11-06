"
Core to the behavior tree. this is where we check if one of our blackboard booleans is true
we can also pass custom functions. There is an expect true flag that we can use as a built in invertor
example: only do something is HAS_LOS is false we can pass expect true = false and return a success
"
extends BTDecorator
class_name BTCondition

# Mode A: use a blackboard bool key
var key: String = ""
var expect_true: bool = true

# Mode B: or supply a custom predicate
var predicate: Callable = Callable()

func tick(blackboard, delta: float) -> int:
	var ok := true

	if predicate.is_valid():
		ok = bool(predicate.call(blackboard)) #checks custom function if its true
	elif key != "":
		var val = blackboard.get_value(key, false)
		ok = bool(val) == expect_true # return value and compare to expect true

	if not ok:
		return Status.FAILURE # return fail if we failed

	if child:
		return child.tick(blackboard, delta) #if we have a child under this like an action it ticks just that child
	return Status.SUCCESS #if no child below it just returns success, i checked it, its true
