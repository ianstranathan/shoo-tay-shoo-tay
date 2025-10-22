extends Control

@export var quit_btn: Button
@export var start_btn: Button


func _ready() -> void:
	quit_btn.pressed.connect(on_quit_btn_pressed)


func restart():
	visible = true
	start_btn.text = "RESTART"


func on_quit_btn_pressed():
	get_tree().quit()
