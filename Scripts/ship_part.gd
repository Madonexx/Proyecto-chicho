extends RigidBody2D

var is_being_carried: bool = false
@onready var soga: Sprite2D = $soga
@onready var orientacion = randi_range(1, 2)
@onready var rotar_valor = randf_range(0.001,0.009)

func _physics_process(_delta: float) -> void:
	girar_parte()

func pickup():
	is_being_carried = true
	soga.visible = true
	collision_layer = 2
	collision_mask = 2
	print(position)

func girar_parte():
	if orientacion == 2:
		orientacion = -1
	rotation += rotar_valor * orientacion

func soltar_parte():
	is_being_carried = false
	soga.visible = false
	print(position)
	collision_layer = 1
	collision_mask = 1
