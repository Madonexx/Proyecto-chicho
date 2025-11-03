extends RigidBody2D

var is_being_carried: bool = false

# El jugador llama a esto cuando la recoge
func pickup():
	is_being_carried = true
	# Congelamos para que no reaccione a la física mientras la cargamos
	freeze = true 

# El jugador llama a esto cuando la suelta
func drop(is_delivered: bool):
	is_being_carried = false
	if not is_delivered:
		# Si no fue entregada (solo soltada),
		# la descongelamos para que la gravedad del planeta le afecte.
		freeze = false
	# Si fue entregada, se queda congelada y el player la destruye.
