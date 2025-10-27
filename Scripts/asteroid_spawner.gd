extends Timer

# Arrastra tu escena Asteroid.tscn aquí
@export var asteroid_scene: PackedScene

# Rango de spawn (ajusta el círculo)
@export var min_radius: float = 300.0
@export var max_radius: float = 600.0

# Rango de velocidad
@export var min_speed: float = 50.0
@export var max_speed: float = 150.0


func _on_timeout():
	# Crear una instancia
	if not asteroid_scene:
		print("Error: No se asignó la escena del asteroide en el Spawner.")
		return
		
	var asteroid = asteroid_scene.instantiate() as RigidBody2D

	# Elegir una posición aleatoria en un círculo
	var random_angle = randf_range(0, TAU) # TAU = 2 * PI (un círculo)
	var random_radius = randf_range(min_radius, max_radius)
	var spawn_position = Vector2.RIGHT.rotated(random_angle) * random_radius
	
	asteroid.global_position = spawn_position
	
	# Asignar una velocidad aleatoria (el script del asteroide la usará)
	# Nota: Asegúrate de que tu script OrbitalObject.gd esté en el asteroide
	asteroid.initial_speed = randf_range(min_speed, max_speed)
	
	# Añadir a la escena
	get_parent().add_child(asteroid)
