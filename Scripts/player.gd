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



#Nuevo agarre de partes
var carried_part: RigidBody2D = null
@onready var grabber_area: Area2D = $Grabber

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

# --- Lógica de Agarrar/Soltar ---
	if Input.is_action_just_pressed("interact"):
		if carried_part:
			# Si ya estamos cargando algo, lo soltamos
			drop_part()
		else:
			# Si no, intentamos recoger algo
			pickup_part()


func pickup_part():
	# Revisa todos los cuerpos físicos que la "mano" está tocando
	var bodies = grabber_area.get_overlapping_bodies()
	
	for body in bodies:
		# Si uno de esos cuerpos es una "ship_part"...
		if body.is_in_group("ship_parts"):
			# Guardamos la referencia
			carried_part = body
			
			# ¡Llamamos a la función del script de la parte!
			carried_part.pickup(self)
			
			print("¡Parte recogida!")
			break # Dejamos de buscar, solo podemos cargar una


func drop_part():
	if not carried_part:
		return

	# Revisa si estamos en la zona de entrega
	var areas = grabber_area.get_overlapping_areas()
	for area in areas:
		# Si la "mano" está tocando la "ship_base"...
		if area.is_in_group("ship_base"):
			
			# ¡ES UNA ENTREGA!
			print("¡Parte entregada!")
			
			# 1. Llama a la función de Main.gd para sumar puntos
			get_parent().deliver_part()
			
			# 2. Destruye la parte
			carried_part.queue_free()
			carried_part = null
			return # Salimos de la función

	# --- Si no es una entrega, es un "drop" normal ---
	print("Parte soltada.")
	
	var part_to_drop = carried_part
	carried_part = null
	
	# ¡Llamamos a la función del script de la parte!
	# Le decimos que el nuevo "padre" es la escena Main (get_parent())
	# y que la suelte en nuestra posición actual
	part_to_drop.drop(get_parent(), global_position)
