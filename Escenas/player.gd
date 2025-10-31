extends CharacterBody2D

# --- Variables de Movimiento ---
const TANGENTIAL_SPEED = 100.0   # Velocidad de movimiento alrededor (A/D)
const THRUST_SPEED = 500.0       # Velocidad de impulso radial (W/S)
const GRAVITY_STRENGTH = 400.0   # Fuerza de la gravedad que atrae al planeta

@onready var sefue = false
@onready var flipado = false
@onready var sprite_2d: Sprite2D = $Sprite2D


# --- Variables del Planeta ---
const PLANET_CENTER = Vector2.ZERO # El centro del planeta
var min_radius = 50.0             # Radio mínimo (para no caer "dentro" del planeta)
var max_radius = 200.0             # Radio máximo

func flip():
	if flipado == true:
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false
	
func _input(event):
	# Detección cuando la tecla A (ui_left) es PRESIONADA
	if event.is_action_pressed("izquierda"):
		flipado = true
		flip()
		
	# Detección cuando la tecla D (ui_right) es PRESIONADA
	if event.is_action_pressed("derecha"):
		flipado = false
		flip()

func _physics_process(delta):
	# 1. --- Cálculo de Direcciones ---
	# Vector que apunta desde el jugador hacia el centro del planeta
	var radial_direction = (PLANET_CENTER - global_position).normalized()
	
	# Vector que apunta perpendicularmente a la dirección radial (para movimiento A/D)
	var tangent_direction = radial_direction.rotated(deg_to_rad(90))

	# 2. --- Aplicar Gravedad ---
	# La gravedad es una fuerza constante que tira hacia el centro.
	var gravity_force = radial_direction * GRAVITY_STRENGTH
	
	# Sumamos la fuerza de gravedad a la velocidad (aceleración por delta)
	velocity += gravity_force * delta
	
	# 3. --- Input de Movimiento Tangencial (A y D) ---
	var rotation_input = Input.get_axis("derecha", "izquierda")
	
	
	
	# La velocidad tangencial se aplica directamente en el eje X de la velocidad
	# Nota: Utilizamos el 'tangent_direction' para asegurar que el movimiento es correcto
	var target_tangential_velocity = tangent_direction * rotation_input * TANGENTIAL_SPEED
	print(target_tangential_velocity)
	# Para un movimiento más suave, podemos interpolar la velocidad (opcional)
	# velocity = velocity.lerp(target_tangential_velocity + (radial_direction * velocity.dot(radial_direction)), 0.1)
	
	# Para simplificar: Reemplazamos el componente tangencial de la velocidad actual 
	# con la nueva velocidad deseada, manteniendo el componente radial intacto.
	var radial_velocity_component = velocity.dot(-radial_direction) # Velocidad de alejamiento/acercamiento
	velocity = target_tangential_velocity - (radial_direction * radial_velocity_component)

	# 4. --- Input Radial de Impulso (W y S) ---
	# Esto permite al jugador "impulsarse" hacia adentro (W) o hacia afuera (S)
	var radial_thrust = Input.get_axis("acercar", "alejar") # S (alejarse) - W (acercarse)
	
	# 5. --- Restricciones de Radio (Colisión con Planeta) ---
	var current_radius = global_position.distance_to(PLANET_CENTER)
	
	
	if radial_thrust != 0 and sefue == false:
		# Aplicamos el impulso como una fuerza
		var thrust_force = radial_direction * radial_thrust * THRUST_SPEED
		velocity += thrust_force * delta
	elif sefue == true:
		var thrust_force = radial_direction * radial_thrust * THRUST_SPEED
		velocity -= thrust_force * delta
	
	if current_radius < min_radius:
		# Si estamos muy cerca, empujamos al jugador hacia afuera
		#var push_out_direction = (global_position - PLANET_CENTER).normalized()
		#global_position = PLANET_CENTER + push_out_direction * min_radius
		# Y eliminamos la velocidad radial para que no siga cayendo
		velocity = velocity.project(tangent_direction)
	
	# 6. --- Rotación del Personaje ---
	# Gira al jugador para que su "arriba" (eje Y) apunte lejos del planeta
	look_at(PLANET_CENTER)
	rotation += deg_to_rad(-90)

	# 7. --- Mover y Deslizar ---
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	sefue = true
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	sefue = false
