extends Node2D

@onready var controller: Node = $DialogueController
@onready var dialogue_ui: Control = $UI/DialogueUI 
@onready var choices_overlay: Control = $UI/ChoicesOverlay

func _ready() -> void:
	print("GameScreen ready")
	controller.line_changed.connect(dialogue_ui.show_line)
	controller.choices_changed.connect(choices_overlay.show_choices)
	var data: DialogueData = load("res://Data/Dialogue/test_data.tres")
	if data == null:
		push_error("Не удалось загрузить DialogueData")
		return
	
	var dialogue_dict: Dictionary = data.to_dict()
	controller.start(dialogue_dict)

# отображат полную строку текста  если 
func _unhandled_input(event) -> void:
	"""
	 надо будет посмотреть по списку действий, мне не нравится стандартный ui_select, по идее должен быть клик мышкой
	"""
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"): 
		# если сейчас показывается выбор — Enter/клик не листает дальше
		if choices_overlay.visible:
			return

		if dialogue_ui.typing:
			dialogue_ui.finish_typing()
		else:
			controller.next()
