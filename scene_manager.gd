extends Node

## Текущая активная сцена
var current_scene : Node 

## Смена сцены
func change_scene(scene_path : String):
	if current_scene:
		current_scene.queue_free()
	
	## Новая сцена
	var scene = load(scene_path).instantiate()
	
	# Добавление и отображение новой сцены
	# call_deferred откладывает вызов функции до конца текущей фазы обработки узлов
	get_tree().root.call_deferred("add_child", scene)
	current_scene = scene
