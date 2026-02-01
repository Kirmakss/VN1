extends Node

signal line_changed(line: Dictionary)
signal choices_changed(line: Array)

var dialogue: Dictionary = {}
var current_id: String = "start"

func _ready() -> void:
	print("dialogue_controller ready:", get_path())

## Начало диалога
func start(dialogue_data: Dictionary) -> void:
	dialogue = dialogue_data
	current_id = "start"
	_emit_current()

## переход к следующей реплике
func next() -> void:
	var line = dialogue.get(current_id, null)
	if line == null:
		push_error("No line id: " + current_id)
		return
		
	# не переходим если есть выборы
	if line.has("choices"):
		return

	if line.has("next"):
		current_id = str(line["next"])
		_emit_current()

## функция перейти к (для выборов)
func goto(id: String) -> void:
	current_id = id
	_emit_current()

## посылаем сигнал о том что сделали
func _emit_current() -> void:
	var line = dialogue.get(current_id, null)
	if line == null:
		push_error("No line id: " + current_id)
		return
		
	_apply_entry_flags(line)
	emit_signal("line_changed", line)
	# готовим выборы, убирая лишние, если надо
	emit_signal("choices_changed", _filter_choices(line.get("choices", [])))


## изменяем флаги после выбора
func _apply_entry_flags(line: Dictionary) -> void:
	if line.has("set_flags"):
		for flag_name in line["set_flags"]:
			FlagsManager.set_flag(flag_name, true)

	if line.has("clear_flags"):
		for flag_name in line["clear_flags"]:
			FlagsManager.clear_flag(flag_name)

## убираем выборы, которые недоступны из за текущих флагов
func _filter_choices(raw_choices: Array) -> Array:
	var result: Array = []

	for choice in raw_choices:
		var ok := true

		if choice.has("required_flags"):
			for f in choice["required_flags"]:
				if not FlagsManager.has_flag(f):
					ok = false
					break

		if ok and choice.has("forbidden_flags"):
			for f in choice["forbidden_flags"]:
				if FlagsManager.has_flag(f):
					ok = false
					break

		if ok:
			result.append(choice)
			
	return result
