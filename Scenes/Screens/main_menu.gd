extends Control


func _on_start_pressed():
	get_node("/root/Main/SceneManager").change_scene("res://Scenes/Screens/GameScreen.tscn")
	print("main_menu выполнен")
