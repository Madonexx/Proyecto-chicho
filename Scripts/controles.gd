extends Control

@onready var mouseizquierda: AnimatedSprite2D = $mouseizquierda

func _ready() -> void:
	mouseizquierda.play("mouseizquierda")

func _on_button_button_down() -> void:
	SceneManager.cambiar_escena("res://Escenas/main.tscn")
