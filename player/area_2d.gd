@tool
extends Area2D

@export var coll_polygon: CollisionPolygon2D
@export var coll_shape: CollisionShape2D

"""
Small utility to not forget about changing the collision shapes
"""

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and coll_shape.polygon != $CollisionPolygon2D.polygon:
		$CollisionPolygon2D.polygon = coll_shape.polygon
