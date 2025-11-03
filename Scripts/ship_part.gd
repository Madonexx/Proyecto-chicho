extends RigidBody2D

# Esta variable nos dirá si el jugador la está cargando
var is_being_carried: bool = false

# Esta función será llamada por el JUGADOR cuando la recoja
func pickup(player_node: Node2D):
	if is_being_carried:
		return

	is_being_carried = true

	# Hacemos que la parte sea hija del jugador
	# Esto hace que se mueva automáticamente con el jugador
	reparent(player_node)

	# La posicionamos justo "encima" de la cabeza del jugador (ajusta esto)
	position = Vector2(0, -60)

	# Nos aseguramos de que siga "congelada" y no cause colisiones raras
	freeze = true 


# Esta función será llamada por el JUGADOR si la suelta
func drop(new_parent: Node, drop_position: Vector2):
	if not is_being_carried:
		return

	is_being_carried = false

	# La devolvemos a la escena principal (Main)
	reparent(new_parent)

	# La colocamos donde estaba el jugador
	global_position = drop_position

	# La "descongelamos" para que la gravedad le afecte si la suelta
	freeze = false
