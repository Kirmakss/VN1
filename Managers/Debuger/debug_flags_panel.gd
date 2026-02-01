extends Control

@onready var flags_label: RichTextLabel = $Panel/VBoxContainer/FlagsLabel
@onready var ids_label: RichTextLabel   = $Panel/VBoxContainer/IdsScroll/IdsLabel
@onready var goto_input: LineEdit       = $Panel/VBoxContainer/HBoxContainer/GotoInput
@onready var goto_button: Button        = $Panel/VBoxContainer/HBoxContainer/GotoButton

# действие для показа/скрытия панели (добавь в Input Map, например на F3)
@export var toggle_action: String = "debug_console"

func _ready() -> void:
	visible = false
	_refresh()

	goto_input.text_submitted.connect(_on_goto_submitted)
	goto_button.pressed.connect(_on_goto_pressed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(toggle_action):
		visible = not visible
		if visible:
			_refresh()
			goto_input.grab_focus()

	if visible:
		_refresh()


# --- ОБНОВЛЕНИЕ ПАНЕЛИ ---

func _refresh() -> void:
	_update_flags_text()
	_update_ids_text()


func _get_controller() -> Node:
	# если GameScreen или имя узла другие – поправь путь тут
	return get_node_or_null("/root/GameScreen/DialogueController")


# --- ФЛАГИ ---

func _update_flags_text() -> void:
	var lines: Array[String] = []

	if FlagsManager.flags.is_empty():
		lines.append("FLAGS: (пока нет)")
	else:
		lines.append("FLAGS:")
		for name in FlagsManager.flags.keys():
			lines.append("  %s = %s" % [name, str(FlagsManager.flags[name])])

	flags_label.text = "\n".join(lines)


# --- СПИСОК ВСЕХ ID ---

func _update_ids_text() -> void:
	var controller := _get_controller()
	if controller == null:
		ids_label.text = "IDS: (нет контроллера)"
		return

	# Диалог хранится в поле dialogue твоего DialogueController
	var dict: Dictionary = controller.dialogue

	if dict.is_empty():
		ids_label.text = "IDS: (диалог пуст или не стартовал)"
		return

	var ids: Array = dict.keys()
	ids.sort()

	var lines: Array[String] = []
	lines.append("IDS:")
	for id in ids:
		lines.append("  " + str(id))

	ids_label.text = "\n".join(lines)


# --- ПЕРЕХОД К ID ---

func _on_goto_submitted(text: String) -> void:
	_goto_id(text)

func _on_goto_pressed() -> void:
	_goto_id(goto_input.text)

func _goto_id(raw_id: String) -> void:
	var id := raw_id.strip_edges()
	if id == "":
		return

	var controller := _get_controller()
	if controller == null:
		flags_label.text += "\n[error]Не найден DialogueController[/error]"
		return

	controller.goto(id)
