extends Control

signal start_pressed

@export var quit_btn: Button
@export var start_btn: Button


func _ready() -> void:
	quit_btn.pressed.connect(on_quit_btn_pressed)
	start_btn.pressed.connect( func(): 
		emit_signal( "start_pressed"))
	#self.visibility_changed.connect( on_visibility_changed )
		
func restart():
	visible = true
	start_btn.text = "RESTART"


func on_quit_btn_pressed():
	get_tree().quit()


#func on_visibility_changed():
	## This function fires EVERY time the actual visible property changes
	#print("VISIBILITY CHANGED TO: ", visible, " from stack: ", get_stack())
