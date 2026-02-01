extends Control

@onready var choices_box: VBoxContainer = $Panel/ChoicesBox
@onready var controller: Node = get_node("/root/GameScreen/DialogueController")

func _ready() -> void:
	visible = false

func show_choices(choices: Array) -> void:
	# удалить старые кнопки
	for child in choices_box.get_children():
		child.queue_free()

	if choices.is_empty():
		visible = false
		return

	visible = true
	
	# создание кнопок
	for choice_data in choices:
		var btn := Button.new()
		btn.text = str(choice_data.get("text", ""))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_ALL
		btn.pressed.connect(_on_choice_pressed.bind(choice_data))
		choices_box.add_child(btn)

	# фокус на первой кнопке (удобно для клавиатуры/геймпада)
	if choices_box.get_child_count() > 0:
		var first_btn := choices_box.get_child(0)
		if first_btn is Button:
			first_btn.grab_focus()

func _on_choice_pressed(choice_data: Dictionary) -> void:
	visible = false
	var next_id := str(choice_data.get("next", ""))
	if next_id == "":
		return
	controller.goto(next_id)
