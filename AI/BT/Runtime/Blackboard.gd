extends RefCounted
class_name Blackboard

signal changed(key: String, value)   # emitted on set()

var _d: Dictionary = {}

func reset(defaults: Dictionary) -> void:
	_d = defaults.duplicate(true)
	for k in _d.keys():
		changed.emit(k, _d[k])

func set_value(key: String, value) -> void:
	_d[key] = value
	changed.emit(key, value)

func get_value(key: String, default_value = null):
	return _d.get(key, default_value)

func debug_print(prefix := "[BB] ") -> void:
	for k in _d.keys():
		print(prefix, k, " = ", _d[k])

	
	
