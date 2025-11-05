extends Area2D
# --- Variables de Movimiento ---
@export var rotation_speed: float = 2.5   # Velocidad de A/D (radianes/seg)
@export var radial_speed: float = 150.0  # Velocidad del mouse (píxeles/seg)
@export var planet_node: Area2D 
# Distancia max y min sobre el radio del planeta.
@export var min_radius: float = 150.0 
@export var max_radius: float = 600.0
var current_angle: float = 0.0     # Nuestro ángulo orbital
var current_radius: float = 200.0  # Nuestra distancia al centro
@onready var sprite_2d: Sprite2D = $Sprite2D

# --- Variables de Agarre 
var carried_part: RigidBody2D = null
@onready var grabber_area: Area2D = $Grabber
#Variable de offset entre el asset del astronauta y el asset de la parte
@export var carry_offset: Vector2 = Vector2(0, -20)


func _ready():
	# Calcula la posición inicial basada en dónde lo pusiste en el editor
	if planet_node:
		var start_vector = global_position - planet_node.global_position
		current_angle = start_vector.angle()
		current_radius = start_vector.length()

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("izquierda"): # A o flecha izq
		current_angle -= rotation_speed * delta
		sprite_2d.flip_h = true
	
	if Input.is_action_pressed("derecha"): # D o flecha der
		current_angle += rotation_speed * delta
		sprite_2d.flip_h = false

	if Input.is_action_pressed("acercar"): # Click Izq
		current_radius -= radial_speed * delta
	
	if Input.is_action_pressed("alejar"): # Click der
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
	
	if carried_part:
		# Calculamos el offset "arriba" del jugador, rotado con el jugador
		var rotated_offset = carry_offset.rotated(rotation)
		# Movemos la parte a esa posición global
		carried_part.global_position = global_position + rotated_offset
		# (Opcional) hacer que la parte rote junto con el jugador
		carried_part.rotation = rotation


func pickup_part():
	var bodies = grabber_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("ship_parts"):
			if body.is_being_carried:
				continue
			carried_part = body
			carried_part.pickup()
			print("Parte agarrada")
			break

func drop_part():
	if not carried_part:
		return
	var areas = grabber_area.get_overlapping_areas()
	var delivered = false
	
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
	carried_part.drop(false)
	carried_part = null

#Condicion de derrota
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("asteroids"):
		print("¡CHOQUE! Has perdido.")
		get_tree().reload_current_scene()
