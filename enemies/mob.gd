@tool
extends CharacterBody2D

"""
This is just a small stand in class
All relevant data is exposed in editor:
	Radius will change shader + collision shapes
	src color is delf evident
	flash decay modifier changes how rapidly the flash juice fades (i.e. c in exp(-c * time))
"""
@export_category("Appearance")
## changes shader sdf + collision shapes
@export var radius: float = 20.0:
	set = set_radius
@export var src_color: Color = Color(1.0, 0.0, 1.0, 0.0) :
	set = set_col
## changes how rapidly the flash juice fades (i.e. c in exp(-c * time))
@export_range(1.0, 7.0, 0.1) var flash_decay_modifier: float = 5.0

@export_category("Movement")
@export var speed: float = 150.0
@export var steering_strength: float = 0.1
@export var rotation_speed: float = 8

@export_category("Behavior")
@export var detection_radius: float = 24
@export var stop_distance: float = 45
var attack_comp: PackedScene = preload("res://enemies/melee_attack_cone.tscn")

var can_hit: bool

enum EnemyState {IDLE, CHASING, ATTACKING, WAITING, PATROLLING, SEARCHING}
var state: EnemyState = EnemyState.IDLE

var target: CharacterBody2D

signal died
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	set_radius( radius )
	
	set_col(src_color)
	
	set_det_radius(detection_radius) #radius to look for enemy
	
	#-----------------------------Timers
	$MeleeCooldownTimer.timeout.connect( func(): can_hit = true)
	$AttackPauseTimer.timeout.connect(execute_attack)
	$MoveDelayTimer.timeout.connect( func(): state = EnemyState.CHASING)
	
	# ----------------------------- Signals
	$HitboxComponent.was_hit.connect( take_hit )
	$HealthComponent.health_changed.connect( func( ratio: float):
		$Sprite2D.material.set_shader_parameter("health", ratio))
	$HealthComponent.health_depeleted.connect(  func(): 
		emit_signal("died")
		queue_free())
	
	$DetectionArea.player_lost_found.connect(player_lost_found)
	$DetectionArea.target_ID.connect( func(b: Player): target = b)

	# -----------------------------
	# -- navigation agent stuff
	# navigation_agent.path_postprocessing = 1
	# -- this will change to an awareness radius or whatever
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = stop_distance
	navigation_agent.debug_enabled = true


func _process(delta: float) -> void:
	modulate_color()



func _physics_process(delta: float) -> void:
	
	if target and state == EnemyState.CHASING:
		move_to_target(delta)


func set_radius( r: float) -> void:
	$CollisionShape2D.shape.radius = r
	$HitboxComponent/CollisionShape2D2.shape.radius = r
	$Sprite2D.material.set_shader_parameter("l", r / (0.5 * $Sprite2D.texture.get_size().x))


func set_col(col: Color) -> void: 
	$Sprite2D.material.set_shader_parameter("src_color", col)


func take_hit( attack :AttackComponent):
	$ColorModulationTimer.start()
	$HealthComponent.take_damge( attack.damage )


func modulate_color():
	if !$ColorModulationTimer.is_stopped():
		# -- we're just feeding the shader a value between 0 and 1 for variable t
		$Sprite2D.material.set_shader_parameter("t", Utils.normalized_timer($ColorModulationTimer))



#------------------------------------------------------------
#Behavior Functions
#check if enemy is in any of the following states. If so enemy is busy
func is_busy() -> bool:
	return state in [EnemyState.ATTACKING, EnemyState.WAITING]#waiting might be redundant
	
func set_det_radius( r: float) -> void:
	$DetectionArea/CollisionShape2D3.shape.radius = r

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
"I like this to handle different things when the enemy finds and loses the target
this might end up being a heavy handed way to handle this but works for now"
func player_lost_found(lost_found)-> void:
	match lost_found:
		"Lost":
			state = EnemyState.SEARCHING
			$MoveDelayTimer.stop()
		"Found":
			state = EnemyState.WAITING
			$MoveDelayTimer.start()

"TODO: 
* Throttle set_movement_target either with a timer or track last known position 
	and check difference or a combination of both. 
* Dont call start_attack when navigation finishes, write a function to check distance to target
* Add line of sight
* Flocking behavior or some kind of steering to avoid obstacles
* accel and decel so enemy doesnt feel so weightless
"
func move_to_target(delta: float) -> void:
	if state == EnemyState.CHASING:
		set_movement_target( target.global_position )
		if navigation_agent.is_navigation_finished():
			start_attack() #should set up function to check distance instead of calling here
			return
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		
		#Rotation
		var desired_dir = current_agent_position.direction_to(next_path_position)
		var desired_ang = desired_dir.angle()
		rotation = lerp_angle(rotation, desired_ang, rotation_speed * delta)
		
		#Velocity
		var desired_vel = desired_dir * speed
		var steering_force = (desired_vel - velocity) * steering_strength
		velocity += steering_force
		velocity = velocity.limit_length(speed)
		move_and_slide()

func start_attack():
	if !can_hit or is_busy():
		return
		
	can_hit = false
	state = EnemyState.ATTACKING
	$AttackPauseTimer.start()
	
		
#Called by AttackPauseTimer
func execute_attack():
	var meleeScene = attack_comp.instantiate()
	add_child(meleeScene)
	meleeScene.global_position = $AttackSpawnPoint.global_position
	
	
	state = EnemyState.WAITING
	$MoveDelayTimer.start()
	$MeleeCooldownTimer.start()
