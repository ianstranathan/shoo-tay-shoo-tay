extends CharacterBody2D


func mark_for_teleport():
	$TransmitMark.visible = true


func is_marked() -> bool:
	return $TransmitMark.visible


func set_marked(b: bool):
	$TransmitMark.visible = b
