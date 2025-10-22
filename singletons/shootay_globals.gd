extends Node

var wrapping_buffer = 20.0 # NOTE

var reflection_layer: int = 3
var transmission_layer: int = 4

enum ShootayValues{
	REFLECT,
	TRANSMIT
}

@onready var valid_shootay_vals = ShootayValues.values()
