extends Node2D

@onready var controller: Node = $DialogueController
@onready var dialogue_ui: Control = $UI/DialogueUI 

func _ready() -> void:
	print("GameScreen ready")
	controller.line_changed.connect(dialogue_ui.show_line)

	var test_dialogue = {
		"start": {"speaker":"Алиса", "text":"Привет!", "next":"2"},
		"2": {"speaker":"Боб", "text":"О, привет. Как дела?", "next":"3"},
		"3": {"speaker":"Алиса", "text":"Проверка диалога работает ✅"}
	}
	controller.start(test_dialogue)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		controller.next()
