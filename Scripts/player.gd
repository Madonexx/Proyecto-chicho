extends CharacterBody2D

@export var vel_rotacion_jugador: float = 2.5
@export var vel_jetpack_jugador: float = 150
@onready var planet: RigidBody2D = $"../Planet"
@onready var gravedad = 1
@export var superficie_planeta: float = 52
var angulo_actual: float = 0.0
var radio_actual: float = 50.0
@onready var sprite_2d: Sprite2D = $Sprite2D

var parte_enganchada: RigidBody2D = null
@onready var distancia_parte = 0
@onready var pos_actual_parte
@onready var area_de_enganche: Area2D = $gancho
@onready var gancho: Sprite2D = $gancho/Sprite2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fuego_jetpack: AnimatedSprite2D = $fuegojetpack
@onready var muerte: AudioStreamPlayer2D = $muerte

func _ready():
	if planet:
		var vector_inicial = global_position - planet.global_position
		angulo_actual = vector_inicial.angle()
		radio_actual = vector_inicial.length()

func _physics_process(delta: float) -> void:
	vel_rotacion_jugador = 100 / radio_actual
	vel_jetpack_jugador = 150
	if parte_enganchada:
		vel_rotacion_jugador /= 2
	caida(delta)
	
	if pos_actual_parte:
		var distancia_x = global_position.x - pos_actual_parte.global_position.x
		var distancia_y = global_position.y - pos_actual_parte.global_position.y
		distancia_parte = abs(distancia_x + distancia_y)
	
	mover_personaje(delta)
	usar_jetpack(delta)
	radio_actual = max(radio_actual, superficie_planeta)
	
	var centro_planeta = planet.global_position
	var desplazamiento = Vector2.RIGHT.rotated(angulo_actual) * radio_actual
	global_position = centro_planeta + desplazamiento
	var direction_to_planet = (centro_planeta - global_position).normalized()
	rotation = direction_to_planet.angle() - deg_to_rad(90)

	if Input.is_action_just_pressed("interact"):
		soltar_o_agarrar()
	
func mover_personaje(delta):
	if Input.is_action_pressed("izquierda"):
		angulo_actual -= vel_rotacion_jugador * delta
		sprite_2d.flip_h = true
		gancho.flip_h = true
		gancho.offset.x = 30
	
	if Input.is_action_pressed("derecha"):
		angulo_actual += vel_rotacion_jugador * delta
		sprite_2d.flip_h = false
		gancho.flip_h = false
		gancho.offset.x = -30

func usar_jetpack(delta):
	if Input.is_action_pressed("alejar"):
		particulas_jetpack()
		if gravedad > 1:
			gravedad /= 2
		radio_actual += vel_jetpack_jugador * delta

func soltar_o_agarrar():
	if parte_enganchada:
		drop_part()
	else:
		pickup_part()
			
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
		copia_fuego.reparent(planet)
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
			pos_actual_parte = body.get_child(0)
			parte_enganchada = body
			parte_enganchada.pickup()
			print("Parte agarrada")
			break

func drop_part():
	var areas = area_de_enganche.get_overlapping_areas()
	var delivered = false
	gancho.visible = false
	
	for area in areas:
		if area.is_in_group("ship_base"):
			entregar_parte()
			delivered = true
			break

	if delivered:
		parte_enganchada = null
		return
		
	print("Parte soltada.")
	parte_enganchada.soltar_parte()
	parte_enganchada = null

func entregar_parte():
	print("¡Parte entregada!")
	get_parent().deliver_part()
	parte_enganchada.queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	radio_actual -= vel_jetpack_jugador * 0.1

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("asteroids"):
		print("¡CHOQUE! Has perdido.")
		set_physics_process(false)
		animated_sprite_2d.visible = true
		sprite_2d.visible = false
		animated_sprite_2d.play()
		muerte.play()
		await animated_sprite_2d.animation_finished
		SceneManager.cambiar_escena("res://Escenas/Defeat.tscn")
