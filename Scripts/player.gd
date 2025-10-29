extends CharacterBody2D

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("move_left"): # "A"
		position.x = position.x -1
	if Input.is_action_pressed("move_right"): # "D"
		position.x = position.x +1
	if Input.is_action_pressed("move_up"): # "W"
		position.y = position.y -1
	if Input.is_action_pressed("move_down"): # "S"
		position.y = position.y +1

	move_and_slide()
