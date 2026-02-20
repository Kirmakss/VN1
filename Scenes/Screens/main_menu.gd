extends Control

@onready var new_game_button: Button    = $Panel/ButtonsInMenu/NewGameButton
@onready var continue_button: Button    = $Panel/ButtonsInMenu/ContinueButton
@onready var settings_button: Button    = $Panel/ButtonsInMenu/SettingsButton
@onready var exit_button: Button        = $Panel/ButtonsInMenu/ExitButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_new_game_pressed() -> void:
	# Путь к твоему игровому экрану
	get_tree().change_scene_to_file("res://Scenes/Screens/GameScreen.tscn")


func _on_continue_pressed() -> void:
	# Пока нет полноценной системы сейвов — просто заглушка
	# Позже сюда воткнём SaveManager.load_game(...)
	print("Продолжить: здесь позже будет загрузка сохранения")


func _on_settings_pressed() -> void:
	# Пока тоже заглушка. Можно:
	# - открыть отдельную сцену настроек,
	# - или показать Settings-попап поверх меню.
	print("Настройки: здесь позже будет открываться меню настроек")


func _on_exit_pressed() -> void:
	get_tree().quit()
