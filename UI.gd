extends CanvasLayer

var tower_preview = null
var tower_range = 750


func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://" + tower_type + ".tscn").instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff3c")
	var range_texture = Sprite2D.new()
	range_texture.position = Vector2(0,0) 
	
	var scaling = GameData.tower_data[tower_type]["range"] / 600.0 #the 1st brackets is what you are looking for and the 2nd is what you are getting from
	range_texture.scale = Vector2(scaling, scaling)
	var texture = load("res://players/range_overlay.png")
	range_texture.texture = texture
	range_texture.modulate = Color("ad54ff3c")
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)

	control.position = mouse_position
	control.set_name("TowerPreview")
	add_child(control, true)
	move_child(get_node("TowerPreview"), 0)


# If the tower is not the correct color, change it
func update_tower_preview(new_position, color):
	get_node("TowerPreview").position = new_position
	# Center range_texture relative to drag_tower
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
		get_node("TowerPreview/Sprite2D").modulate = Color(color)


func remove_tower_preview():
	if tower_preview:
		tower_preview.queue_free()
		tower_preview = null

# Fix for missing UI/TowerPreview node
func cancel_build_mode():
	var ui_node = get_node_or_null("UI")
	if ui_node:
		var tower_preview_node = ui_node.get_node_or_null("TowerPreview")
		if tower_preview_node:
			tower_preview_node.queue_free()
	
##
## Game controll functions
##


func _on_PausePlay_pressed():
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if get_tree().is_paused():
		get_tree().paused = false
		
	elif get_parent().current_wave == 0:
		get_parent().current_wave += 1
		get_parent().start_next_wave()
	else:
		get_tree().paused = true


func _on_SpeedUp_pressed() -> void:
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)
