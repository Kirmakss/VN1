extends Node2D

@onready var controller: Node = $DialogueController
@onready var dialogue_ui: Control = $UI/DialogueUI 

func _ready() -> void:
	print("GameScreen ready")
	controller.line_changed.connect(dialogue_ui.show_line)

	var test_dialogue = {
  "start": {"speaker":"Алиса", "text":"Привет!", "next":"2"},

  "2": {"speaker":"Алиса", "text":"Куда пойдём?",
		"choices":[
		  {"text":"В лес", "next":"forest"},
		  {"text":"В город", "next":"city"}
		]
  },

  "forest": {"speaker":"Боб", "text":"Лес так лес.", "next":"end"},
  "city":   {"speaker":"Боб", "text":"Город так город.", "next":"end"},
  "end":    {"speaker":"Алиса", "text":"Конец теста ✅"}
}

	controller.start(test_dialogue)

# отображат полную строку текста  если 
func _unhandled_input(event) -> void:
	"""
	 надо будет посмотреть по списку действий, мне не нравится стандартный ui_select, по идее должен быть клик мышкой
	"""
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"): 
		if dialogue_ui.typing:
			dialogue_ui.typing = false
			dialogue_ui.finish_typing()
		else:
			controller.next()
