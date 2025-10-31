extends Node2D

var shootay_explosion_scene: PackedScene = preload("res://vfx/grenade_explosion_dummy/grenade_explosion_dummy.tscn")
# NOTE
# -- CHANGE_ME
# -- there should probably be a material lookup at collision to decide what it looks like
# -- but just one impact particle for now
var impact_particles: PackedScene = preload("res://particle_effects/reflect_impact.tscn")

func _ready() -> void:
	GlobalSignals.shootay_exploded.connect( func(pos: Vector2):
		var _expl = shootay_explosion_scene.instantiate()
		add_child(_expl)
		_expl.global_position = pos)

func make_collision_particle(pos: Vector2, normal: Vector2) -> void:
	var p = impact_particles.instantiate()
	add_child(p)
	p.finished.connect( func(): p.queue_free())
	p.global_position = pos
	p.global_rotation = Vector2.RIGHT.angle_to( normal )
	p.emitting = true
