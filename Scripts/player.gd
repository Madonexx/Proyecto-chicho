extends CharacterBody2D

@onready var player: CharacterBody2D = $"."

@onready var superficie = $"../Planet"
@onready var vel_gravedad = 100
@onready var velocidad = 100

@onready var asteroid: Node2D = $"../Asteroid"

@onready var radionum = 0.85

@onready var radio_a = radionum   # El radio horizontal de la elipse
@onready var radio_b = radionum    # El radio vertical de la elipse

var progreso_orbita = 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("izquierda"): # "A"
		
		progreso_orbita -= velocidad * _delta
		var nueva_posicion = Vector2()
		nueva_posicion.x = superficie.global_position.x + radionum * cos(progreso_orbita)
		nueva_posicion.y = superficie.global_position.y + radionum * sin(progreso_orbita)
		
		position =  position - nueva_posicion

	if Input.is_action_pressed("derecha"): # "D"
		progreso_orbita += velocidad * _delta
		var nueva_posicion = Vector2()
		nueva_posicion.x = superficie.global_position.x + radionum * cos(progreso_orbita)
		nueva_posicion.y = superficie.global_position.y + radionum * sin(progreso_orbita)
		
		position =  position + nueva_posicion

	
	mover_jugador()
	ajustar_gravedad(delta)

	move_and_slide()
	gravedad_jugador()


func mover_jugador():
	#if Input.is_action_pressed("izquierda"): # "A"
		#position.x = position.x -00.1
	if Input.is_action_pressed("derecha"): # "D"
		position.x = position.x +0
		

func gravedad_jugador():
	position -= position.normalized() * vel_gravedad
	

func ajustar_gravedad(delta):
	var distancia = 0.0
	var distanciax = 0.0
	var distanciay = 0.0
	distanciax = abs(position.x - superficie.global_position.x)
	distanciay = abs(position.y - superficie.global_position.y)
	distancia = distanciax + distanciay
	#print("distanciay", distanciay)
	#print("distanciax", distanciax)
	print("distancia", distancia)
	#var divisor = 65.88
	#velocidad = distancia / divisor
	#radionum = distancia / divisor
	#print("velocidad", velocidad)
	print("radio", radionum)
	print(progreso_orbita)
	#print(superficie.global_position, $"../Planet/CollisionShape2D".global_position)
	
	if Input.is_action_pressed("acercar"):
		position = position.move_toward(superficie.position, vel_gravedad * delta)
		if radionum > radionum:
			radionum -= 0.02
			#progreso_orbita -= 0.03
	
	if Input.is_action_pressed("alejar"):
		var alejarse = position.normalized()
		position += alejarse * vel_gravedad * delta
		if radionum < 2.25:
			position += alejarse
			radionum += 0.02
			#progreso_orbita -= 0.03
		
		pass
	pass
