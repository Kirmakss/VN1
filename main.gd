extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Main loaded")
	$SceneManager.change_scene("res://Scenes/Screens/GameScreen.tscn")
	
