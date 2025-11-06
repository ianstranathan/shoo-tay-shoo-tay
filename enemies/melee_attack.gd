extends Area2D
class_name MeleeAttack

@export var damage: int = 10
@export var attack_range: float = 60.0
@export var attack_arc_deg: float = 90.0
@export var debug_draw: bool = false

"This one needs some love. these examples im finding to create a cone and see if the player is in it seem
like way too much. is there a better way?"
func attack() -> bool:
	var forward := Vector2.RIGHT.rotated(global_rotation)
	var half_cone := deg_to_rad(attack_arc_deg) * 0.5

	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			print("Player in cone during attack")
			var dir := body.global_position - global_position
			if dir.length() <= attack_range:
				var angle: float = abs(forward.angle_to(dir.normalized()))
				if angle <= half_cone:
					var playerHB = body.get_node_or_null("HitboxComponent")
					playerHB.take_hit(self)
					return true
	return false
	
	
func _draw() -> void:
	if not debug_draw:
		return
	var half_cone := deg_to_rad(attack_arc_deg) * 0.5
	draw_arc(Vector2.ZERO, attack_range, -half_cone, half_cone, 24, Color(1,0,0,0.3), 2)
	draw_line(Vector2.ZERO, Vector2.RIGHT.rotated(-half_cone) * attack_range, Color(1,0,0,0.5))
	draw_line(Vector2.ZERO, Vector2.RIGHT.rotated( half_cone) * attack_range, Color(1,0,0,0.5))
