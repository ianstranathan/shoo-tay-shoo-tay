@tool
extends Node

#@export var _area2D: Area2D
#@export var coll_geo : Node2D
#
#func _process(delta: float) -> void:
	#if Engine.is_editor_hint():
		## -- just delete the area's collision geometry and replace
		#var coll_geometry = _area2D.get_children().filter( func(child):
			#(child is CollisionShape2D or child is CollisionPolygon2D))
		#if coll_geometry != coll_geo:
			#coll_geometry.queue_free()
			#print("deleted area 2d's collision geometry")
			#_area2D.add_child(coll_geo
