extends Node
func cambiar_escena(ruta_escena: String):
	get_tree().call_deferred("change_scene_to_file", ruta_escena)

func salir_del_juego():
	get_tree().quit()
