extends CharacterBody2D

@onready var player: CharacterBody2D = $"."

@onready var superficie = $"../Planet"
@onready var vel_gravedad = 1
@onready var velocidad = 1

@onready var asteroid: Node2D = $"../Asteroid"

@onready var radio_a = 0.9         # El radio horizontal de la elipse
@onready var radio_b = 0.9         # El radio vertical de la elipse

var progreso_orbita = 0.0

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("izquierda"): # "A"
		
		progreso_orbita -= velocidad * _delta
		var nueva_posicion = Vector2()
		nueva_posicion.x = superficie.global_position.x + radio_a * cos(progreso_orbita)
		nueva_posicion.y = superficie.global_position.y + radio_b * sin(progreso_orbita)
		
		position =  position - nueva_posicion

	if Input.is_action_pressed("derecha"): # "D"
		progreso_orbita += velocidad * _delta
		var nueva_posicion = Vector2()
		nueva_posicion.x = superficie.global_position.x + radio_a * cos(progreso_orbita)
		nueva_posicion.y = superficie.global_position.y + radio_b * sin(progreso_orbita)
		
		position =  position + nueva_posicion

	
	mover_jugador()
	ajustar_gravedad()
	move_and_slide()
	#gravedad_jugador()


func mover_jugador():
	#if Input.is_action_pressed("izquierda"): # "A"
		#position.x = position.x -00.1
	if Input.is_action_pressed("derecha"): # "D"
		position.x = position.x +0
		

#func gravedad_jugador():
	#position -= position.normalized() * vel_gravedad
	

func ajustar_gravedad():
	var distancia = 0.0
	var distanciax = 0.0
	var distanciay = 0.0
	distanciax = abs(position.x - superficie.global_position.x)
	distanciay = abs(position.y - superficie.global_position.y)
	distancia = distanciax + distanciay
	print("distanciay", distanciay)
	print("distanciax", distanciax)
	print(distancia)
	var divisor = 55
	#velocidad = distancia / divisor
	#radio_a = distancia / divisor
	#radio_b = distancia / divisor
	print("velocidad", velocidad)
	print("radio b", radio_b)
	print("radio a", radio_a)
	
	if Input.is_action_pressed("acercar"):
		position = position.move_toward(superficie.position, vel_gravedad)
	
	if Input.is_action_pressed("alejar"):
		var alejarse = position.normalized()
		position += alejarse * 2
		pass
	pass
