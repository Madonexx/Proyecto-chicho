extends Control

func _on_button_pressed() -> void:
	SceneManager.cambiar_escena("res://Escenas/main.tscn")

func _on_button_2_pressed() -> void:
	SceneManager.cambiar_escena("res://Escenas/MainMenu.tscn")
