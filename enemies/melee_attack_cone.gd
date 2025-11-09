extends Node2D
class_name MeleeAttackCone

var bodies_hit = []

func _ready():
	var lifetime_timer = Timer.new()
	add_child(lifetime_timer)
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = 0.2
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start()
	


func _on_area_2d_area_entered(area):
	if area is HitboxComponent and area.is_in_group("Player"):
		area.take_hit($AttackComponent)
