extends Control

@onready var name_bg_left: Panel = $DialogWindow/NameBG_left
@onready var name_bg_top: Panel = $DialogWindow/NameBG_top
@onready var text_bg: Panel = $DialogWindow/TextBG

@onready var speaker_label: RichTextLabel = $DialogWindow/NameContent/Speaker
@onready var text_label: RichTextLabel = $DialogWindow/TextContent/Text

func show_line(line: Dictionary) -> void:
	speaker_label.text = str(line.get("speaker", ""))
	text_label.text = str(line.get("text", ""))
	print("DialogWindow show_line:", speaker_label.text)
