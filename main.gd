extends Node

@export var UI: Control

# -- TODO temp prototype restart
var restarted = false

func _ready():
	$Game.game_over.connect( end_game )
	$Game.visible = false
	$Game.process_mode = Node.PROCESS_MODE_DISABLED
	UI.started_game.connect( start_game )


func start_game():
	$CanvasLayer/HUD.visible = true
	$Game.visible = true
	$Game.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# -- TODO temp prototype restart
	if !restarted:
		restarted = true
	else:
		$Game.restart()
		$CanvasLayer/HUD.clear_shootay_meter()


func end_game():
	UI.visible = true
	$CanvasLayer/HUD.visible = false
	$Game.visible = false
	$Game.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
