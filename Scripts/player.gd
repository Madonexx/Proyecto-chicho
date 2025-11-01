extends CharacterBody2D

@onready var superficie = $"../Planet"
@onready var vel_gravedad = 100

func _physics_process(delta: float) -> void:

	mover_jugador()
	ajustar_gravedad(delta)

	move_and_slide()

func mover_jugador():
	if Input.is_action_pressed("izquierda"): # "A"
		position.x = position.x -1
	if Input.is_action_pressed("derecha"): # "D"
		position.x = position.x +1

func ajustar_gravedad(delta):
	if Input.is_action_pressed("acercar"):
		position = position.move_toward(superficie.position, vel_gravedad * delta)
	
	if Input.is_action_pressed("alejar"):
		var alejarse = position.normalized()
		position += alejarse * vel_gravedad * delta
