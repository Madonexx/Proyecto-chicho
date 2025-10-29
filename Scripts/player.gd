extends CharacterBody2D

@onready var superficie = $"../Planet"
@onready var vel_gravedad = 1

func _physics_process(_delta: float) -> void:

	mover_jugador()
	ajustar_gravedad()

	move_and_slide()

func mover_jugador():
	if Input.is_action_pressed("move_left"): # "A"
		position.x = position.x -1
	if Input.is_action_pressed("move_right"): # "D"
		position.x = position.x +1

func ajustar_gravedad():
	if Input.is_action_pressed("acercar"):
		position = position.move_toward(superficie.position, vel_gravedad)
	
	if Input.is_action_pressed("alejar"):
		var alejarse = position.normalized()
		position += alejarse * vel_gravedad
		pass
	pass
