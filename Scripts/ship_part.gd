extends RigidBody2D

var is_being_carried: bool = false

func pickup():
	is_being_carried = true
	freeze = true 

func drop(is_delivered: bool):
	is_being_carried = false
	
	#Este codigo depende de nosotros queremos que se congele la nave cuando la suelto o que tome fisica?
	# if not is_delivered:
		# Si no fue entregada (solo soltada),
		# la descongelamos para que la gravedad del planeta le afecte.
		#freeze = false
	# Si fue entregada, se queda congelada y el player la destruye.
