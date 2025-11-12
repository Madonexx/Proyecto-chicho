extends CharacterBody2D
# --- Variables de Movimiento ---
@export var rotation_speed: float = 2.5   # Velocidad de A/D (radianes/seg)
@export var radial_speed: float = 150.0  # Velocidad del mouse (píxeles/seg)
@export var planet_node: Area2D 
@onready var gravedad = 1
@onready var can_move = true
# Distancia max y min sobre el radio del planeta.
@export var min_radius: float = 52.0 
@export var max_radius: float = 600.0
var current_angle: float = 0.0     # Nuestro ángulo orbital
var current_radius: float = 50.0  # Nuestra distancia al centro
@onready var sprite_2d: Sprite2D = $Sprite2D

# --- Variables de Agarre 
var carried_part: RigidBody2D = null

@onready var grabber_area: Area2D = $gancho
@onready var gancho: Sprite2D = $gancho/Sprite2D
#Variable de offset entre el asset del astronauta y el asset de la parte
@export var carry_offset: Vector2 = Vector2(0, -20)

@onready var distanciaparte = 0
@onready var partedenaveahora

#animaciones
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fuegojetpack: AnimatedSprite2D = $fuegojetpack


#sonidos del player
@onready var muerte: AudioStreamPlayer2D = $muerte

func _ready():
	# Calcula la posición inicial basada en dónde lo pusiste en el editor
	if planet_node:
		#
		var start_vector = global_position - planet_node.global_position
		current_angle = start_vector.angle()
		current_radius = start_vector.length()

func _physics_process(delta: float) -> void:
	#arregla la hiper velocidad del pj al alejarse del planeta
	
	
	rotation_speed = 100 / current_radius
	radial_speed = 150
	if carried_part:
		rotation_speed /= 2
		#radial_speed /= 1.4
	
	if can_move == true:
		caida(delta)
	
	
	#por si la parte de la nave se bugea y se aleja del jugador
	if partedenaveahora:
		var distanciax = global_position.x - partedenaveahora.global_position.x
		var distanciay = global_position.y - partedenaveahora.global_position.y
		distanciaparte = abs(distanciax + distanciay) 
		
	if distanciaparte > 70:
		if carried_part:
			drop_part()
	
	if Input.is_action_pressed("izquierda") and can_move == true: # A o flecha izq
		current_angle -= rotation_speed * delta
		sprite_2d.flip_h = true
		gancho.flip_h = true
		gancho.offset.x = 30
	
	if Input.is_action_pressed("derecha") and can_move == true: # D o flecha der
		current_angle += rotation_speed * delta
		sprite_2d.flip_h = false
		gancho.flip_h = false
		gancho.offset.x = -30

	if Input.is_action_pressed("acercar") and can_move == true: # Click Izq
		current_radius -= radial_speed * delta

	
	if Input.is_action_pressed("alejar") and can_move == true: # Click der
		#numero para la rotacion
		var num = randi_range(1,4)
		#numero para el ejex
		var num2 = randi_range(-5, 5)
		#numero para el ejeY
		var num3 = randi_range(-5, 2)
		duplicar_borrar(num, num2, num3)
		if gravedad > 1:
			gravedad /= 2
			#gravedad = gravedad - 4.5
		current_radius += radial_speed * delta
		
	# Evita que el jugador se meta al planeta o se vaya muy lejos
	current_radius = clamp(current_radius, min_radius, max_radius)

	# Posiciones
	# Obtenemos la posición central del planeta
	var planet_center = planet_node.global_position
	# Calculamos el offset (desplazamiento)
	var offset = Vector2.RIGHT.rotated(current_angle) * current_radius
	global_position = planet_center + offset

	# Hacemos que los "pies" apunten al planeta
	var direction_to_planet = (planet_center - global_position).normalized()
	rotation = direction_to_planet.angle() - deg_to_rad(90)

	# --- 6. Lógica de Agarre
	if Input.is_action_just_pressed("interact"):
		if carried_part:
			drop_part()
		else:
			pickup_part()
	
	#if carried_part:
		# Calculamos el offset "arriba" del jugador, rotado con el jugador
		#var rotated_offset = carry_offset.rotated(rotation)
		# Movemos la parte a esa posición global
		#carried_part.global_position = global_position + rotated_offset
		# (Opcional) hacer que la parte rote junto con el jugador
		#carried_part.rotation = rotation

func duplicar_borrar(num, num2, num3):
		var copiafuego = fuegojetpack.duplicate()
		copiafuego.visible = true
		copiafuego.play()
		
		if num == 1:
			copiafuego.rotation = 0
		elif num == 2:
			copiafuego.rotation = 90
		elif num == 3:
			copiafuego.rotation = 180
		else:
			copiafuego.rotation = 270
		
		copiafuego.position.x += num2 
		copiafuego.position.y += num3
		add_child(copiafuego)
		copiafuego.reparent(planet_node)
		await get_tree().create_timer(0.4).timeout
		copiafuego.queue_free()

func caida(delta):
	#limite de la gravedad maxima
	if gravedad < 200:
		gravedad += 2.3
	current_radius -= gravedad * delta

func pickup_part():
	var bodies = grabber_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("ship_parts"):
			gancho.visible = true
			#es importante que el sprite este donde esta para que esto fucione
			partedenaveahora = body.get_child(0)
			carried_part = body
			carried_part.pickup()
			print("Parte agarrada")
			break

func drop_part():
	var areas = grabber_area.get_overlapping_areas()
	var delivered = false
	gancho.visible = false
	
	for area in areas:
		if area.is_in_group("ship_base"):
			print("¡Parte entregada!")
			get_parent().deliver_part()
			carried_part.queue_free()
			delivered = true
			break

	if delivered:
		carried_part = null
		return
		
	print("Parte soltada.")
	carried_part.soltar_parte()
	carried_part = null
	

#Condicion de derrota

#func _on_area_entered(area: Area2D) -> void:
	
		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	current_radius -= radial_speed * 0.1


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("asteroids"):
		print("¡CHOQUE! Has perdido.")
		can_move = false
		animated_sprite_2d.visible = true
		sprite_2d.visible = false
		animated_sprite_2d.play()
		muerte.play()
		await animated_sprite_2d.animation_finished
		
		SceneManager.cambiar_escena("res://Escenas/Defeat.tscn")
