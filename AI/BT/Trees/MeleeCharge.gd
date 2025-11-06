extends Resource
class_name MeleeCharge

const BTSelector        = preload("res://AI/BT/Runtime/BTSelector.gd")
const BTSequence        = preload("res://AI/BT/Runtime/BTSequence.gd")
const BTMoveToTarget    = preload("res://AI/BT/Tasks/BTMoveToTarget.gd")
const BTFaceTarget      = preload("res://AI/BT/Tasks/BTFaceTarget.gd")
const BTMeleeAttack     = preload("res://AI/BT/Tasks/BTMeleeAttack.gd")
const BTDistanceWithin  = preload("res://AI/BT/Tasks/BTDistanceWithin.gd")
const BTCooldown        = preload("res://AI/BT/Tasks/BTCooldown.gd")
const BBKeys            = preload("res://AI/BT/Common/BBKeys.gd")

func build(enemy: CharacterBody2D, blackboard) -> BTRunner:
	var move := BTMoveToTarget.new()
	move.nav = enemy.navigation_agent
	move.repath_interval = enemy.repath_interval

	var in_melee := BTDistanceWithin.new()
	in_melee.key_distance = BBKeys.DESIRED_MELEE

	var face := BTFaceTarget.new()
	face.actor = enemy

	var attack := BTMeleeAttack.new()
	attack.component = enemy.get_node_or_null("MeleeAttack")

	var attack_cd := BTCooldown.new() #cooldown isnt working - what do?
	attack_cd.cooldown_time = 0.6
	attack_cd.set_child(attack)


	var root := BTSelector.new()

	
	var seq_attack := BTSequence.new()
	seq_attack.add_child(face)
	seq_attack.add_child(attack_cd)
	seq_attack.add_child(in_melee)
	seq_attack.add_child(attack_cd)

	
	var seq_move := BTSequence.new()
	seq_attack.add_child(face)
	seq_move.add_child(move)

	root.add_child(seq_attack)
	root.add_child(seq_move)

	var runner := BTRunner.new()
	runner.set_tree(root, blackboard)
	return runner
