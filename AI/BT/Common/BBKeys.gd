extends RefCounted
class_name BBKeys

#Agent Scope Keys
const TARGET :="target" #Most likely the player
const TARGET_POS := "target_pos"
const DISTANCE :="distance" #distance to target

const HAS_LOS :="has_los" #does agent have line of sight to target
const ENGAGED := "engaged" #is agent engaged in combat

const DESIRED_RANGED :="desired_range" #how far from target agent is trying to get for ranged attack
const DESIRED_MELEE :="desired_melee"#how far from target agent is trying to get for melee attack
const STOP_DISTANCE   := "stop_distance"   #current active stop distance

const CAN_RANGED := "can_ranged"
const CAN_MELEE := "can_melee"

const IS_PATH_BLOCKED := "is_path_blocked"
const FLEE_DIR        := "flee_dir" #setting up in case we want agent to run away from player or attacks

# Default values used by the Blackboard on reset/init
const DEFAULTS := {
	TARGET: null,
	TARGET_POS: Vector2.ZERO,
	DISTANCE: INF,

	HAS_LOS: false,
	ENGAGED: false,

	DESIRED_RANGED: 220.0,
	DESIRED_MELEE: 48.0,
	STOP_DISTANCE: 220.0, 

	CAN_RANGED: true,
	CAN_MELEE: true,

	IS_PATH_BLOCKED: false,
	FLEE_DIR: Vector2.ZERO,
}
