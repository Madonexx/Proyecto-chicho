extends CharacterBody2D

@export var vel_rotacion_jugador: float = 2.5
@export var vel_jetpack_jugador: float = 150
@export var planet_node: Area2D 
@onready var gravedad = 1
@onready var can_move = true
@export var superficie_planeta: float = 52
var angulo_actual: float = 0.0
var radio_actual: float = 50.0
@onready var sprite_2d: Sprite2D = $Sprite2D

var fragmento_enganchado: RigidBody2D = null
@onready var distancia_parte = 0
@onready var pos_actual_fragmento
@onready var area_de_enganche: Area2D = $gancho
@onready var gancho: Sprite2D = $gancho/Sprite2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fuego_jetpack: AnimatedSprite2D = $fuegojetpack
@onready var muerte: AudioStreamPlayer2D = $muerte

func _ready():
	# Calcula la posición inicial basada en dónde lo pusiste en el editor
	if planet_node:
		#
		var start_vector = global_position - planet_node.global_position
		angulo_actual = start_vector.angle()
		radio_actual = start_vector.length()

func _physics_process(delta: float) -> void:
	#arregla la hiper velocidad del pj al alejarse del planeta
	
	
	vel_rotacion_jugador = 100 / radio_actual
	vel_jetpack_jugador = 150
	if fragmento_enganchado:
		vel_rotacion_jugador /= 2
		#radial_speed /= 1.4
	
	caida(delta)
	
	
	#por si la parte de la nave se bugea y se aleja del jugador
	if pos_actual_fragmento:
		var distancia_x = global_position.x - pos_actual_fragmento.global_position.x
		var distancia_y = global_position.y - pos_actual_fragmento.global_position.y
		distancia_parte = abs(distancia_x + distancia_y) 
		
	if distancia_parte > 70:
		if fragmento_enganchado:
			drop_part()
	
	if Input.is_action_pressed("izquierda") and can_move == true:
		angulo_actual -= vel_rotacion_jugador * delta
		sprite_2d.flip_h = true
		gancho.flip_h = true
		gancho.offset.x = 30
	
	if Input.is_action_pressed("derecha") and can_move == true:
		angulo_actual += vel_rotacion_jugador * delta
		sprite_2d.flip_h = false
		gancho.flip_h = false
		gancho.offset.x = -30

	if Input.is_action_pressed("acercar") and can_move == true:
		radio_actual -= vel_jetpack_jugador * delta

	if Input.is_action_pressed("alejar") and can_move == true:
		particulas_jetpack()
		if gravedad > 1:
			gravedad /= 2
		radio_actual += vel_jetpack_jugador * delta
		
	radio_actual = max(radio_actual, superficie_planeta)

	# Posiciones
	# Obtenemos la posición central del planeta
	var planet_center = planet_node.global_position
	# Calculamos el offset (desplazamiento)
	var offset = Vector2.RIGHT.rotated(angulo_actual) * radio_actual
	global_position = planet_center + offset

	# Hacemos que los "pies" apunten al planeta
	var direction_to_planet = (planet_center - global_position).normalized()
	rotation = direction_to_planet.angle() - deg_to_rad(90)

	# --- 6. Lógica de Agarre
	if Input.is_action_just_pressed("interact"):
		if fragmento_enganchado:
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
func particulas_jetpack():
	var num = randi_range(1,4)
	var num2 = randi_range(-5, 5)
	var num3 = randi_range(-5, 2)
	duplicar_borrar(num, num2, num3)
		
func duplicar_borrar(num, num2, num3):
		var copia_fuego = fuego_jetpack.duplicate()
		copia_fuego.visible = true
		copia_fuego.play()
		
		if num == 1:
			copia_fuego.rotation = 0
		elif num == 2:
			copia_fuego.rotation = 90
		elif num == 3:
			copia_fuego.rotation = 180
		else:
			copia_fuego.rotation = 270
		
		copia_fuego.position.x += num2 
		copia_fuego.position.y += num3
		add_child(copia_fuego)
		copia_fuego.reparent(planet_node)
		await get_tree().create_timer(0.4).timeout
		copia_fuego.queue_free()

func caida(delta):
	if gravedad < 200:
		gravedad += 2.3
	radio_actual -= gravedad * delta

func pickup_part():
	var bodies = area_de_enganche.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("ship_parts"):
			gancho.visible = true
			#es importante que el sprite este donde esta para que esto fucione
			pos_actual_fragmento = body.get_child(0)
			fragmento_enganchado = body
			fragmento_enganchado.pickup()
			print("Parte agarrada")
			break

func drop_part():
	var areas = area_de_enganche.get_overlapping_areas()
	var delivered = false
	gancho.visible = false
	
	for area in areas:
		if area.is_in_group("ship_base"):
			print("¡Parte entregada!")
			get_parent().deliver_part()
			fragmento_enganchado.queue_free()
			delivered = true
			break

	if delivered:
		fragmento_enganchado = null
		return
		
	print("Parte soltada.")
	fragmento_enganchado.soltar_parte()
	fragmento_enganchado = null


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	radio_actual -= vel_jetpack_jugador * 0.1


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
