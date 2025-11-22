extends Node

#@export var player_ref: CharacterBody2D:
	#set = set_children_to_test_mobs
@export var enemy_scene: PackedScene
@export var max_enemies: int =10
@export var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	$SpawnInterval.timeout.connect(can_spawn)
	
func can_spawn() -> void:
	var e_alive : = get_tree().get_nodes_in_group("Enemy").size()
	if e_alive >= max_enemies:
		return
	spawn_enemy()

func spawn_enemy() -> void:
	var enemy : = enemy_scene.instantiate()
	enemy.global_position = set_spawn_location()
	add_child(enemy)
		
func set_spawn_location() -> Vector2:
	return spawn_points[randi() % spawn_points.size()].global_position
	 
#func set_children_to_test_mobs(_player_ref: CharacterBody2D):
#	get_children().map( func(child): child.target = _player_ref)
