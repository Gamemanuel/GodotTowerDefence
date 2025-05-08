extends CanvasLayer

var tower_preview = null

func set_tower_preview(tower_type, mouse_position):
	if tower_preview:
		tower_preview.queue_free() # Remove previous preview

	tower_preview = load("res://" + tower_type + ".tscn").instantiate()
	tower_preview.set_name("TowerPreview")
	tower_preview.modulate = Color("00ff00") # Default to green
	add_child(tower_preview)
	tower_preview.position = mouse_position

# if the tower is not the correct color, change it
func update_tower_preview(new_position, color):
	if tower_preview:
		tower_preview.position = new_position
		tower_preview.modulate = Color(color)

func remove_tower_preview():
	if tower_preview:
		tower_preview.queue_free()
		tower_preview = null
