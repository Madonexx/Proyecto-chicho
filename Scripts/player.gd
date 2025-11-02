extends CharacterBody2D


@onready var player: CharacterBody2D = $"."
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var superficie: RigidBody2D = $"../Planet"

@onready var vel_gravedad = 100

#velocidad del progrso de la orbita del jugador
@onready var velocidad_orbita = 1.05

@onready var asteroid: Node2D = $"../Asteroid"

#radio de la orbita del jugador al estar en la superficie (contra mas alto mas grande la circunferencia)
@onready var radio_a = 0.9
@onready var radio_b = 0.9

var progreso_orbita = 0.0


func _physics_process(delta: float) -> void:

	mover_jugador_planeta(delta)
	
	mover_jugador()
	
	ajustar_gravedad(delta)

	move_and_slide()
	#gravedad_jugador()

func mover_jugador_planeta(delta):
	if Input.is_action_pressed("izquierda"): # "A"
		
		#con este flip el sprite del jugador se da la vuelta en el eje X
		sprite_2d.flip_h = true
		
		progreso_orbita -= velocidad_orbita * delta
		var nueva_posicion = Vector2()
		nueva_posicion.x = superficie.global_position.x + radio_a * cos(progreso_orbita)
		nueva_posicion.y = superficie.global_position.y + radio_b * sin(progreso_orbita)
		
		position =  position - nueva_posicion

	if Input.is_action_pressed("derecha"): # "D"
		
		#con este flip el jugador vuelve a la orientaion del sprite normal
		sprite_2d.flip_h = false
		
		progreso_orbita += velocidad_orbita * delta
		var nueva_posicion = Vector2()
		nueva_posicion.x = superficie.global_position.x + radio_a * cos(progreso_orbita)
		nueva_posicion.y = superficie.global_position.y + radio_b * sin(progreso_orbita)
		
		position =  position + nueva_posicion
	
	#con este look y el cambio de rotacion el jugador rota correspondiendo al planeta,
	#el cambio de rotacion es necesario para que parezca que pisa el planeta.
	look_at(superficie.position)
	rotation += deg_to_rad(-90)

func mover_jugador():
	if Input.is_action_pressed("izquierda"): # "A"
		position.x = position.x -1
	if Input.is_action_pressed("derecha"): # "D"
		position.x = position.x +1
		

#func gravedad_jugador():
	#position -= position.normalized() * vel_gravedad

func ajustar_gravedad(delta):
	if Input.is_action_pressed("acercar"):
		position = position.move_toward(superficie.position, vel_gravedad * delta)
	
	if Input.is_action_pressed("alejar"):
		var alejarse = position.normalized()
		position += alejarse * vel_gravedad * delta
		pass
	pass
