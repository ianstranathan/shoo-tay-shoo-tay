extends Node2D

signal teleport_anim_finished()


func _physics_process(delta: float) -> void:
	global_rotation = 0.0

func teleport():
	$TeleportVisual.visible = true
	var tween = create_tween()
	Utils.shader_float_tween(tween, $TeleportVisual, "control", 0., 1., 0.3, Tween.EaseType.EASE_IN, Tween.TransitionType.TRANS_CUBIC)
	tween.tween_callback( func(): emit_signal("teleport_anim_finished"))
