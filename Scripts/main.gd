extends Node2D

@export var ship_part_scene: PackedScene
@export var total_parts_to_win: int = 5 # Ajusta esto a cuantas partes haya

# Referencias a nodos (arrástralos desde el editor o usa @onready)
@onready var gravity_bar: TextureProgressBar = $UI/GravitationalCalibrator
@onready var parts_label: Label = $UI/PartsLabel

# Contadores del juego
var current_gravity: float
var parts_collected: int = 0


func _ready():
	update_ui()
	spawn_game_objects()

func _process(_delta):
	update_ui()

func update_ui():
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
	# Aquí pones tu lógica para crear partes de la nave
	pass
