extends Resource
class_name DialogueChoice
'''
Хдесь задаются переменные, которые будут указываться при создании выбора в диалоге
'''

@export var text: String
@export var next_id: String

## Вариант показывается ТОЛЬКО если ВСЕ эти флаги установлены
@export var required_flags: Array[String] = []

## Вариант скрывается, если ЛЮБОЙ из этих флагов установлен
@export var forbidden_flags: Array[String] = []
