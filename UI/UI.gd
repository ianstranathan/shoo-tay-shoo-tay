extends Control

signal started_game

@export var HUD: Control

func _ready() -> void:
	# -- toggle UI when game starts
	$StartMenu.start_pressed.connect( func():
		emit_signal( "started_game" )
		visible = false)
	
