extends Node2D

var map_node
var build_mode = false
var build_tile
var build_valid = false
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_node = get_node("Map1") # Turn this into a variable based on selected map

	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", Callable(self, "initiate_build_mode").bind(i.get_name()))  
		 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if build_mode:
		update_tower_preview()

func _unhandled_input(event):
	if event.is_action_released("Cancel_Tower") and build_mode:
		cancel_build_mode()
	if event.is_action_released("Place_Tower") and build_mode:
		verify_and_build()
		cancel_build_mode()

##
## Wave functions
##

func start_next_wave():
	var wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.2).timeout #padding/distance between waves
	spawn_enemies(wave_data)
	
func retrieve_wave_data():
	var wave_data = [["blue_tank", 3.0],["blue_tank", 0.1]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data

func spawn_enemies(wave_data):
	var new_enemy
	for i in wave_data:
		var enemy_scene = load("res://" + i[0] + ".tscn")
		if enemy_scene:
			new_enemy = enemy_scene.instantiate()
		else:
			print("Error loading scene")
		map_node.get_node("Path").add_child(new_enemy, true)
		await get_tree().create_timer(i[1]).timeout
		
		

##
## building functions
##

func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type + "T1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").local_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_local(current_tile)  

	# Corrected placement validation
	if map_node.get_node("TowerExclusion").get_cell_source_id(current_tile) == -1:
		get_node("UI").update_tower_preview(tile_position, "00ff00") # Green for valid placement
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "ff0000") # Red for invalid placement
		build_valid = false

func place_tower():
	build_mode = false
	if build_valid:
		var new_tower = load("res://" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		map_node.add_child(new_tower)
		get_node("UI").remove_tower_preview()

func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()

func verify_and_build():
	if build_valid:
		var new_tower = load("res://" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		new_tower.category = GameData.tower_data[build_type]["category"]
		map_node.get_node("turrets").add_child(new_tower, true)
		var tile_id = 0  # The ID of the tile in the TileSet
		var layer = 0  # The layer where the tile will be placed
		var position = get_global_mouse_position()  # The grid position where the tile will be placed
		map_node.get_node("TowerExclusion").set_cell(build_tile, 1, Vector2i(1,0) ,0)

		## deduct cash
		## update cash label
