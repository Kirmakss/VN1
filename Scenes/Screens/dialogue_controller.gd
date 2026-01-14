extends Node

signal line_changed(line: Dictionary)

var dialogue: Dictionary = {}
var current_id: String = "start"

func _ready() -> void:
	print("DialogWindow ready:", get_path())

## Начало диалога
func start(dialogue_data: Dictionary) -> void:
	dialogue = dialogue_data
	current_id = "start"
	_emit_current()

func next() -> void:
	var line = dialogue.get(current_id, null)
	if line == null:
		push_error("No line id: " + current_id)
		return

	if line.has("next"):
		current_id = str(line["next"])
		_emit_current()

func _emit_current() -> void:
	var line = dialogue.get(current_id, null)
	if line == null:
		push_error("No line id: " + current_id)
		return
	emit_signal("line_changed", line)
