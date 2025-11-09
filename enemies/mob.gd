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
var chase_player: bool = false
var can_hit: bool
var can_move: bool #using to pause movement - add a reaction time
var is_attacking: bool  #using this to add some delay to melee attack and pause movement.

var target: CharacterBody2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	set_radius( radius )
	
	set_col(src_color)
	
	set_det_radius(detection_radius) #radius to look for enemy
	
	#-----------------------------Timers
	$MeleeCooldownTimer.timeout.connect( func(): can_hit = true)
	$AttackPauseTimer.timeout.connect(attack)
	$MoveDelayTimer.timeout.connect( func(): can_move = true)
	
	# ----------------------------- Signals
	$HitboxComponent.was_hit.connect( take_hit )
	$HealthComponent.health_changed.connect( func( ratio: float):
		$Sprite2D.material.set_shader_parameter("health", ratio))
	$HealthComponent.health_depeleted.connect( func(): queue_free())
	
	$DetectionArea.player_lost_found.connect(player_lost_found)

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
	
	if target and chase_player and !is_attacking:
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

func set_det_radius( r: float) -> void:
	$DetectionArea/CollisionShape2D3.shape.radius = r

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
"I like this to handle different things when the enemy finds and loses the target
this might end up being a heavy handed way to handle this but works for now"
func player_lost_found(lost_found)-> void:
	match lost_found:
		"Lost":
			chase_player = false
			can_move = false
			$MoveDelayTimer.stop()
		"Found":
			chase_player = true
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
	if can_move:
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
	if can_hit and !is_attacking:
		can_hit = false
		can_move = false
		is_attacking = true
		$AttackPauseTimer.start()
		
func attack():
	var meleeScene = attack_comp.instantiate()
	add_child(meleeScene)
	meleeScene.global_position = $AttackSpawnPoint.global_position
	is_attacking = false
	$MoveDelayTimer.start()
	$MeleeCooldownTimer.start()
# --------------------------------------------------------------
# -- This was a polygon2d approach, but it should look better with an sdf + shader

#@export_category("collision and polygon")
#@export var num_pts: int = 50
#@export var radius: float = 20.0:
	#set = set_radius
#
#
## Reference to the node you want to flash (e.g., your visual sprite)
#@onready var visual_node: Node2D = $Polygon2D
#var original_modulate_color: Color 
#
#func _ready():
	## Store the original color when the game starts
	#original_modulate_color = visual_node.modulate
#
#
#func _process(delta: float) -> void:
	#if Engine.is_editor_hint() and !$Polygon2D.polygon:
		#$Polygon2D.polygon = make_circle_pts($CollisionShape2D.shape.radius, num_pts)
		##set_radius( $CollisionShape2D.shape.radius )
#
#func set_radius(r: float):
	#$Polygon2D.polygon = make_circle_pts(r, num_pts)
#
#
#func make_circle_pts(r: float, n: int):
	#var v: PackedVector2Array = []
	#var theta = 0
	#var delta_theta = TAU / float(n)
	#for i in range(n):
		#v.append( r * Vector2(cos(theta), sin(theta)))
		#theta += delta_theta
	#return v
