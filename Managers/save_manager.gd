extends Node

'''
Здесь есть маленькая “неточность” по флагам (set_flags у стартовых реплик может отработать поверх подгруженных), 
но для дебага и базовой системы этого выше крыши. Если потом захочешь сделать идеально,
можно будет добавить в контроллер отдельный метод для “жёсткого” выставления текущего id без переинициализации.
'''

# %d - целое число
const SAVE_PATH_TEMPLATE := "user://save_%d.json"

func save_game(slot: int, game_screen: Node) -> void:
	var path := SAVE_PATH_TEMPLATE % slot

	var controller: Node = game_screen.get_node("DialogueController")

	var data := {
		"dialogue_path": game_screen.dialogue_resource_path,
		"current_id": controller.current_id,
		"flags": FlagsManager.flags,
		"settings": {
			"text_cps": SettingsManager.text_cps,
		}
	}
	# Создает или открывает файл с таким номером сохранения
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Не удалось открыть файл для сохранения: " + path)
		return

	file.store_string(JSON.stringify(data))
	print("Сохранение записано:", path)


func load_game(slot: int, game_screen: Node) -> void:
	var path := SAVE_PATH_TEMPLATE % slot

	if not FileAccess.file_exists(path):
		push_error("Сейв не найден: " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Не удалось открыть файл сохранения: " + path)
		return

	# Преобразование типа string в словарь
	var text := file.get_as_text()
	var parsed: Dictionary = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Некорректный формат сейва: " + path)
		return

	var data: Dictionary = parsed

	# 1) Настройки
	if data.has("settings"):
		var settings: Dictionary= data["settings"]
		if settings.has("text_cps"):
			SettingsManager.text_cps = float(settings["text_cps"])
		# Добавить другие настройки, когда появятся

	# 2) Флаги 
	if data.has("flags"):
		FlagsManager.flags = data["flags"]

	# 3) Диалог
	if not data.has("dialogue_path") or not data.has("current_id"):
		push_error("В сейве нет необходимых данных (dialogue_path/current_id)")
		return

	var dialogue_path: String = data["dialogue_path"]
	var current_id: String = data["current_id"]

	var res: DialogueData = load(dialogue_path)
	if res == null:
		push_error("Не удалось загрузить DialogueData из сейва: " + dialogue_path)
		return

	# Обновляем путь в GameScreen (на случай, если он менялся)
	game_screen.dialogue_resource_path = dialogue_path

	# Запуск текущего диалога и текущей реплики
	var controller: Node = game_screen.get_node("DialogueController")
	var dialogue_dict: Dictionary = res.to_dict()
	controller.start(dialogue_dict)
	controller.goto(current_id)

	print("Сейв загружен:", path)
