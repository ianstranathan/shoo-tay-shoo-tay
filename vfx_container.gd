extends Node2D

var shootay_explosion_scene: PackedScene = preload("res://vfx/grenade_explosion_dummy/grenade_explosion_dummy.tscn")

func _ready() -> void:
	GlobalSignals.shootay_exploded.connect( func(pos: Vector2):
		var _expl = shootay_explosion_scene.instantiate()
		add_child(_expl)
		_expl.global_position = pos)
