extends RigidBody2D

# Ajusta esto en el Inspector para cada objeto
@export var initial_speed: float = 100.0

func _ready():
	# ¡La clave para orbitar!
	# Damos una velocidad inicial perpendicular a la posición.
	
	# Asumimos que el planeta está en (0,0)
	# Vector2.ZERO es la posición del planeta
	var direction_to_planet = (Vector2.ZERO - global_position).normalized()
	
	# .orthogonal() nos da un vector perpendicular (tangencial)
	# Multiplicamos por -1 para que sea en sentido horario (clockwise)
	var tangent_velocity = direction_to_planet.orthogonal() * -1
	
	# Aplicamos la velocidad
	linear_velocity = tangent_velocity * initial_speed
