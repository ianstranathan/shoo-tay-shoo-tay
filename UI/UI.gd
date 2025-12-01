extends Control

signal started_game

func _ready() -> void:
	$StartMenu.start_pressed.connect( func():
		emit_signal( "started_game" )
		visible = false
		)
	
