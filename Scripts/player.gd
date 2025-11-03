# ¡MUY IMPORTANTE! Asegúrate de que hereda de Area2D
extends Area2D

# --- Variables de Movimiento ---
@export var rotation_speed: float = 2.5   # Velocidad de A/D (radianes/seg)
@export var radial_speed: float = 150.0  # Velocidad del mouse (píxeles/seg)

# --- Referencias ---
# ¡Arrastra tu nodo Planeta (el Area2D) aquí en el Inspector!
@export var planet_node: Area2D 

# Mínima distancia (radio del planeta) y máxima
@export var min_radius: float = 150.0 
@export var max_radius: float = 600.0

@onready var sprite_2d: Sprite2D = $Sprite2D

# --- Variables de Agarre (SIN CAMBIOS) ---
var carried_part: RigidBody2D = null
@onready var grabber_area: Area2D = $Grabber

# --- Variables de Posición ---
var current_angle: float = 0.0     # Nuestro ángulo orbital
var current_radius: float = 200.0  # Nuestra distancia al centro


func _ready():
	# Calcula la posición inicial basada en dónde lo pusiste en el editor
	if planet_node:
		var start_vector = global_position - planet_node.global_position
		current_angle = start_vector.angle()
		current_radius = start_vector.length()
	else:
		print("ERROR: ¡El nodo 'planet_node' no está asignado en el Player!")


func _physics_process(delta: float) -> void:
	
	if not planet_node:
		return # No hacer nada si el planeta no está asignado

	# --- 1. Input Rotacional (A/D) ---
	if Input.is_action_pressed("izquierda"): # "A"
		current_angle -= rotation_speed * delta
		sprite_2d.flip_h = true
	
	if Input.is_action_pressed("derecha"): # "D"
		current_angle += rotation_speed * delta
		sprite_2d.flip_h = false

	# --- 2. Input Radial (Mouse) ---
	# Usamos los nombres que tenías: "acercar" y "alejar"
	if Input.is_action_pressed("acercar"):
		current_radius -= radial_speed * delta
	
	if Input.is_action_pressed("alejar"):
		current_radius += radial_speed * delta
	
	# --- 3. Limitar el radio ---
	# Evita que el jugador se meta al planeta o se vaya muy lejos
	current_radius = clamp(current_radius, min_radius, max_radius)

	# --- 4. Calcular y Aplicar Posición ---
	# Obtenemos la posición central del planeta
	var planet_center = planet_node.global_position
	
	# Calculamos el offset (desplazamiento) usando trigonometría
	var offset = Vector2.RIGHT.rotated(current_angle) * current_radius
	
	# ¡Aplicamos la nueva posición directamente!
	global_position = planet_center + offset

	# --- 5. Rotar el Sprite ---
	# Hacemos que los "pies" apunten al planeta
	var direction_to_planet = (planet_center - global_position).normalized()
	rotation = direction_to_planet.angle() - deg_to_rad(90)

	# --- 6. Lógica de Agarre (SIN CAMBIOS) ---
	# Esta lógica funciona igual que antes
	if Input.is_action_just_pressed("interact"):
		if carried_part:
			drop_part()
		else:
			pickup_part()
	
	# ¡YA NO HAY MOVE_AND_SLIDE()!


# --- FUNCIONES DE AGARRE (COPIA Y PEGA TUS FUNCIONES ANTIGUAS) ---
# (Estas funciones no necesitan cambiar en absoluto)

func pickup_part():
	var bodies = grabber_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("ship_parts"):
			carried_part = body
			carried_part.pickup(self)
			print("¡Parte recogida!")
			break

func drop_part():
	if not carried_part:
		return
	var areas = grabber_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("ship_base"):
			print("¡Parte entregada!")
			get_parent().deliver_part()
			carried_part.queue_free()
			carried_part = null
			return

	print("Parte soltada.")
	var part_to_drop = carried_part
	carried_part = null
	part_to_drop.drop(get_parent(), global_position)


func _on_area_entered(area: Area2D) -> void:
# 'area' es el Area2D que entró en nosotros (el Asteroide).
	# Verificamos si esa área pertenece al grupo "asteroids".
	if area.is_in_group("asteroids"):
		
		# ¡COLISIÓN!
		print("¡CHOQUE! Has perdido.")
		
		# Reiniciamos la escena actual
		get_tree().reload_current_scene()
