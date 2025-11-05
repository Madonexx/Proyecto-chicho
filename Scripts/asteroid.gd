extends Node2D
@export var planeta: Node2D
@export var velocidad_orbita = 1   # Qué tan rápido orbita (radianes/seg)
@export var velocidad_rotacion = 1 # Qué tan rápido gira sobre sí mismo
@export var radio_a = 100.0          # El radio horizontal de la elipse
@export var radio_b = 100.0          # El radio vertical de la elipse
var progreso_orbita = 0.0
@onready var sprite = $Sprite2D

func _process(delta):
	progreso_orbita += velocidad_orbita * delta
	# 2. Calcular la nueva posición usando trigonometría (fórmula de la elipse)
	if planeta:
		var centro = planeta.global_position
		var nueva_posicion = Vector2()
		nueva_posicion.x = centro.x + radio_a * cos(progreso_orbita)
		nueva_posicion.y = centro.y + radio_b * sin(progreso_orbita)
		global_position = nueva_posicion
	# Girar el sprite sobre su propio eje
	if sprite:
		sprite.rotate(velocidad_rotacion * delta)
