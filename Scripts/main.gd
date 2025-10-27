extends Node2D

# --- Variables --- #
@export var player_rotation_speed: float = 2.5
@export var gravity_change_speed: float = 100.0
@export var min_gravity: float = 50.0
@export var max_gravity: float = 300.0
# ¡Añade esta línea! Arrastra ShipPart.tscn aquí en el Inspector.
@export var ship_part_scene: PackedScene
@export var total_parts_to_win: int = 5 # Ajusta esto a cuantas partes haya

# Referencias a nodos (arrástralos desde el editor o usa @onready)
@onready var player_pivot: Node2D = $PlayerPivot
@onready var player_node: Area2D = $PlayerPivot/Player
@onready var planet_gravity_area: Area2D = $Planet
@onready var gravity_bar: TextureProgressBar = $UI/GravitationalCalibrator
@onready var parts_label: Label = $UI/PartsLabel

# Contadores del juego
var current_gravity: float
var parts_collected: int = 0


func _ready():
	# Conectar la señal del jugador (Area2D) a una función
	
	# Configurar la gravedad inicial
	current_gravity = planet_gravity_area.gravity
	
	# Configurar la barra de UI
	gravity_bar.min_value = min_gravity
	gravity_bar.max_value = max_gravity
	
	# Actualizar UI
	update_ui()
	
	# Generar las partes de la nave (puedes hacerlo manualmente o por código)
	spawn_game_objects()

func _process(delta):
	# 1. Mover al jugador
	if Input.is_action_pressed("move_left"): # "A"
		player_pivot.rotate(-player_rotation_speed * delta)
	if Input.is_action_pressed("move_right"): # "D"
		player_pivot.rotate(player_rotation_speed * delta)

	# 2. Ajustar gravedad
	if Input.is_action_pressed("decrease_gravity"): # Botón Izquierdo Mouse
		current_gravity -= gravity_change_speed * delta
	if Input.is_action_pressed("increase_gravity"): # Botón Derecho Mouse
		current_gravity += gravity_change_speed * delta
	
	# Limitar la gravedad y actualizar la UI
	current_gravity = clamp(current_gravity, min_gravity, max_gravity)
	planet_gravity_area.gravity = current_gravity
	update_ui()


func update_ui():
	gravity_bar.value = current_gravity
	parts_label.text = "Partes: %d / %d" % [parts_collected, total_parts_to_win]


func _on_player_area_entered(area: Area2D):
	# La 'area' que entró es la Hitbox. Queremos su "padre" (el RigidBody).
	var body = area.get_parent()

	if body.is_in_group("asteroids"):
		# ¡Derrota!
		print("¡CHOQUE! Has perdido.")
		get_tree().reload_current_scene() # Reinicia el juego

	if body.is_in_group("ship_parts"):
		# ¡Parte recogida!
		parts_collected += 1
		body.queue_free() # Elimina la parte
		update_ui()
		
		# ¡Victoria!
		if parts_collected >= total_parts_to_win:
			print("¡HAS GANADO! Nave reparada.")
			# Aquí pones la lógica de victoria (ej. cambiar de escena)
			get_tree().paused = true # Pausa el juego


func spawn_game_objects():
	# Aquí pones tu lógica para crear asteroides y partes de la nave
	# Por ahora, nos enfocamos en el script de esos objetos.
	pass
