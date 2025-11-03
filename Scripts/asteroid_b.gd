extends Node2D
## Exporta las variables para ajustarlas desde el Inspector
@export var planeta: Node2D          # Arrastra tu nodo 'Planeta' aquí
@export var velocidad_orbita = 2   # Qué tan rápido orbita (radianes/seg)
@export var velocidad_rotacion = 2 # Qué tan rápido gira sobre sí mismo
@export var radio_a = 200.0          # El radio horizontal de la elipse
@export var radio_b = 200.0          # El radio vertical de la elipse

# Variable interna para rastrear el progreso de la órbita
var progreso_orbita = 0.0

# Obtenemos la referencia al sprite para hacerlo girar
@onready var sprite = $Sprite2D

func _process(delta):
	# 1. Incrementar el progreso de la órbita
	progreso_orbita += velocidad_orbita * delta
	
	# 2. Calcular la nueva posición usando trigonometría (fórmula de la elipse)
	if planeta:
		var centro = planeta.global_position
		var nueva_posicion = Vector2()
		nueva_posicion.x = centro.x + radio_a * cos(progreso_orbita)
		nueva_posicion.y = centro.y + radio_b * sin(progreso_orbita)
		
		# Asignar la posición global al asteroide
		global_position = nueva_posicion
	
	# 3. Girar el sprite sobre su propio eje
	if sprite:
		sprite.rotate(velocidad_rotacion * delta)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("¡El jugador ha perdido!")

		# Se recarga la escena o se muestra escena de game over o le sacamos una vida
		get_tree().reload_current_scene()
		
		# O puedes llamar a una función en el jugador:
		# if body.has_method("morir"):
		#     body.morir()
