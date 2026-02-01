extends Resource
class_name DialogueData

@export var entries: Array[DialogueEntry] = []
# преобразование бд в словарь для дальнейшей обработки
func to_dict() -> Dictionary:
	var result: Dictionary = {}
	for entry in entries:
		# обработка ошибки id
		if entry.id == "":
			push_error("DialogueEntry без id: " + str(entry))
			continue

		# добавлении текста и спикера
		var line: Dictionary = {
			"speaker": entry.speaker,
			"text": entry.text
		}

		# добавление следующего id
		if entry.next_id != "":
			line["next"] = entry.next_id

		# добавление выборов
		if not entry.choices.is_empty():
			var choices_array: Array = []
			for c in entry.choices:
				var choice_dict := {
					"text": c.text,
					"next": c.next_id
				}
				# добавление флагов
				if not c.required_flags.is_empty():
					choice_dict["required_flags"] = c.required_flags
				if not c.forbidden_flags.is_empty():
					choice_dict["forbidden_flags"] = c.forbidden_flags
				choices_array.append(choice_dict)
			line["choices"] = choices_array
		
		# запись о добавлении и удалении флагов после этого выбора
		if not entry.set_flags_on_enter.is_empty():
			line["set_flags"] = entry.set_flags_on_enter

		if not entry.clear_flags_on_enter.is_empty():
			line["clear_flags"] = entry.clear_flags_on_enter

		result[entry.id] = line
	return result
