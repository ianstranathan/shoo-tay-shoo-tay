extends Node2D

var can_melee_again := true
@export var delay_after_anim_timer: Timer

func _ready() -> void:
	# reset shader anim in case it's forgotten'
	assert($Sprite2D)
	$Sprite2D.visible = false
	$Sprite2D.material.set_shader_parameter("rad", 0.0)
	
	delay_after_anim_timer.timeout.connect( func():
		can_melee_again = true)


func do_melee():
	can_melee_again = false
	$Sprite2D.visible = true
	var tween = create_tween()
	
	tween.tween_property( $Sprite2D, "material:shader_parameter/rad", 0.75, 0.3
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_callback( func():
		$Sprite2D.visible = false
		$Sprite2D.material.set_shader_parameter("rad", 0.0)
		delay_after_anim_timer.start())


func _physics_process(delta: float) -> void:
	if ((Input.is_action_just_pressed("shoot reflect") and Input.is_action_just_pressed("shoot transmit")) or 
		Input.is_action_just_pressed("SPACE") and can_melee_again):
		do_melee()
