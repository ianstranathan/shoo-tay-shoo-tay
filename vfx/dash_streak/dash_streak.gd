extends Node2D

var dash_effect_running := false
#var shader_tween: Tween

# -- TODO
# -- Kill shader_tween if the player is running into a wall or something
var particle_pos_closure: Callable
var streak_ratio_closure: Callable
func start_dashing( player: CharacterBody2D, dir: Vector2, speed: float, timer: Timer) -> void:
	# ----------------------------------------------- streak stuff
	var distance_streaked = speed * timer.wait_time
	scale_direction_line(distance_streaked)
	
	var player_pos_at_dash_time = player.global_position
	$Sprite2D.global_position = player_pos_at_dash_time + dir.normalized() * (distance_streaked / 2.0)
	$Sprite2D.visible = true
	
	var angle_to_rot = Vector2.RIGHT.angle_to( dir )
	$Sprite2D.global_rotation = angle_to_rot
	dash_effect_running = true
	#shader_tween = create_tween()
	#shader_tween.tween_property($Sprite2D, "material:shader_parameter/t", 1.0, 1.2 * timer.wait_time)

	# ----------------------------------------------- after image particles
	$GPUParticles2D.emitting = true
	$GPUParticles2D.material.set_shader_parameter("alpha", angle_to_rot)
	$GPUParticles2D.lifetime = timer.wait_time
	particle_pos_closure = func(): $GPUParticles2D.global_position = player.global_position
	
	var total_dash = dir.normalized() * distance_streaked
	var final_pos = player_pos_at_dash_time + total_dash
	streak_ratio_closure = func(): return (final_pos - player.global_position).length() / distance_streaked

func _process(delta: float) -> void:
	if dash_effect_running:
		particle_pos_closure.call()
		$Sprite2D.material.set_shader_parameter("t", 1. - streak_ratio_closure.call())

func scale_direction_line(dist: float):
	$Sprite2D.scale.x = dist / $Sprite2D.texture.get_size().x


func stop_dashing():
	$Sprite2D.material.set_shader_parameter("t", 0.)
	$Sprite2D.visible = false
	dash_effect_running = false
