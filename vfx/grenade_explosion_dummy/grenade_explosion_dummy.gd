extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.animation_finished.connect( func():
		queue_free())
	$AnimatedSprite2D.play("explosion")
