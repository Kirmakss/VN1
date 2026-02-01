extends Node

var flags: Dictionary = {} # { "имя_флага": bool }

func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value
	print("FLAG SET:", flag_name, "=", value)

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func clear_flag(flag_name: String) -> void:
	flags.erase(flag_name)
	print("FLAG CLEARED:", flag_name)
