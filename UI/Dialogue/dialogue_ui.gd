extends Control

@onready var name_bg_left: Panel = $DialogWindow/NameBG_left
@onready var name_bg_top: Panel = $DialogWindow/NameBG_top
@onready var text_bg: Panel = $DialogWindow/TextBG

@onready var speaker_label: RichTextLabel = $DialogWindow/NameContent/Speaker
@onready var text_label: RichTextLabel = $DialogWindow/TextContent/Text

@onready var controller = get_node("/root/GameScreen/DialogueController") # пока никак не используется

var full_text := ""
## Условие окончания вывода строки
var typing := false
## Текущее количество отображенных символов
var progress := 0.0
## Символы в секунду (Значение можно менять в инспекторе, при этом то что в коде будет считаться по умолчанию)
#SettingsManager.text_cps

#func _ready() -> void:
	#set_process(true)

func _process(delta: float) -> void:
	if not typing:
		return

	progress += SettingsManager.text_cps * delta
	text_label.visible_characters = int(progress)
	
	if text_label.visible_characters >= full_text.length():
		text_label.visible_characters = -1
		typing = false

func show_line(line: Dictionary) -> void:
	speaker_label.text = str(line.get("speaker", ""))
	
	full_text = str(line.get("text", ""))
	text_label.text = full_text
	
	progress = 0.0
	text_label.visible_characters = 0
	typing = true
	
## Мгновенно напечатать текст по клику
func finish_typing() -> void:
	typing = false
	text_label.visible_characters = -1
