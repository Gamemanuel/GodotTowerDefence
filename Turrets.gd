extends Node2D

func _physics_process(delta: float) -> void:
	turn()
	
func turn():
	var enemy_position = get_global_mouse_position()
	enemy_position = Vector2(enemy_position.x, enemy_position.y)
	get_node("Turret").look_at(enemy_position)
	
	# Rotate sprite 90 degrees to the right
	get_node("Turret").rotation_degrees += 90
