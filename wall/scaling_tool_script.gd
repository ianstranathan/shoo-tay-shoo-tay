@tool
extends Sprite2D

@export var collision_shape_to_scale_with: CollisionShape2D

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		#print("yo")
		var _size = scale * texture.get_size()
		material.set_shader_parameter("dims", _size)
		collision_shape_to_scale_with.shape.size = _size
		collision_shape_to_scale_with.notify_property_list_changed()
