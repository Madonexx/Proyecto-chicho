extends RigidBody2D

var is_being_carried: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var soga: Sprite2D = $soga
@onready var posiciontemporal = Vector2(0,0)

func _physics_process(_delta: float) -> void:
	girar_parte()

func pickup():
	is_being_carried = true
	soga.visible = true
	#freeze = true
	collision_layer = 2
	collision_mask = 2
	print(position)

@onready var quelado = randi_range(1, 2)
@onready var rotarvalor = randf_range(0.001,0.009)

func girar_parte():
	if quelado == 2:
		quelado = -1
	
	rotation += rotarvalor * quelado

func drop(_is_delivered: bool):
	is_being_carried = false
	soga.visible = false
	print(position)
	#freeze = false
	collision_layer = 1
	collision_mask = 1
	
	#Este codigo depende de nosotros queremos que se congele la nave cuando la suelto o que tome fisica?
	# if not is_delivered:
		# Si no fue entregada (solo soltada),
		# la descongelamos para que la gravedad del planeta le afecte.
		#freeze = false
	# Si fue entregada, se queda congelada y el player la destruye.
