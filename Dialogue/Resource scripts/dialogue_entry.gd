extends Resource
class_name DialogueEntry
'''
Здесь задаются переменные, которые будут указываться при задании текста в диалоговом окне 
'''

@export var id: String
@export var speaker: String
@export var text: String
@export var next_id: String = ""
@export var choices: Array[DialogueChoice] = []

## Эти флаги будут УСТАНОВЛЕНЫ при входе в эту реплику
@export var set_flags_on_enter: Array[String] = []

## Эти флаги будут СБРОШЕНЫ при входе в эту реплику
@export var clear_flags_on_enter: Array[String] = []
