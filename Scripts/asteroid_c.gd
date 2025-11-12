extends Node2D
@export var planeta: Node2D
@export var velocidad_orbita = 1.5
@export var velocidad_rotacion = 1.5
@export var radio_h = 150 
@export var radio_v = 150
var progreso_orbita = 0
@onready var sprite = $Sprite2D

func _process(delta):
	progreso_orbita += velocidad_orbita * delta
	
	if planeta:
		orbitar()
		
	if sprite:
		sprite.rotate(velocidad_rotacion * delta)

func orbitar():
	var centro = planeta.global_position
	var nueva_posicion = Vector2()
	nueva_posicion.x = centro.x + radio_h * cos(progreso_orbita)
	nueva_posicion.y = centro.y + radio_v * sin(progreso_orbita)
	global_position = nueva_posicion
