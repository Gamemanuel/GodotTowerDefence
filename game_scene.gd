extends Node2D

signal game_finished(won)

var map_node
var build_mode = false
var build_tile
var build_valid = false
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0
var total_waves = -1 # -1 for infinite mode, set a number for finite
var wave_active = false
var enemies_spawned_this_wave = 0
var wave_ended = false
var base_health = 100

# Configuration for initial waves
var waves_data = [
	{"enemies": [["blue_tank", 2.0]], "count": 3},
	{"enemies": [["blue_tank", 1.5]], "count": 5},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_node = get_node("Map1")
	print(GameData.Gold)

	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", Callable(self, "initiate_build_mode").bind(i.get_name()))

	# Connect the game_finished signal to a function in this scene
	connect("game_finished", self._on_game_finished)

	# handel inital gold calculations
	var moneyDisplay = get_node("UI/HUD/UpperMenu/Money/MoneyIcon/Money")
	moneyDisplay.text = str(GameData.Gold)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#update the money node
	var moneyDisplay = get_node("UI/HUD/UpperMenu/Money/MoneyIcon/Money")
	moneyDisplay.text = str(GameData.Gold)
	
	# calculate the movement of the turrent when we drag it with the mouse
	if build_mode:
		update_tower_preview()

	# Check if the current wave is complete
	if wave_active and get_tree().get_nodes_in_group("enemies").size() == 0 and enemies_spawned_this_wave == enemies_in_wave:
		wave_active = false
		wave_ended = true
		var play_button = get_node("UI/HUD/GameControls/PausePlay")
		if is_instance_valid(play_button) and play_button is TextureButton:
			play_button.button_pressed = false

func _unhandled_input(event):
	if event.is_action_released("Cancel_Tower") and build_mode:
		#get_node("UI/HUD/GameControls/PausePlay").disabled = false
		cancel_build_mode()
	if event.is_action_released("Place_Tower") and build_mode:
		#print('disabled')
		#get_node("UI/HUD/GameControls/PausePlay").disabled = true 
		#print(get_node("UI/HUD/GameControls/PausePlay").disabled)
		verify_and_build()
		cancel_build_mode()

##
## Wave functions
##

func start_next_wave():
	wave_ended = false
	current_wave += 1
	print("Starting Wave:", current_wave)
	wave_active = true
	enemies_spawned_this_wave = 0
	var wave_data_to_spawn = []
	var num_to_spawn = 0

	if current_wave <= waves_data.size() and total_waves != -1:
		# Use predefined waves if available and in finite mode
		var wave_data = waves_data[current_wave - 1]
		num_to_spawn = wave_data.count
		for enemy_info in wave_data.enemies:
			wave_data_to_spawn.append(enemy_info)
	else:
		# Procedural wave generation for later/infinite waves
		num_to_spawn = 3 + current_wave * 2 # Increase number of enemies per wave
		wave_data_to_spawn.append(["blue_tank", randf_range(0.3, 1.2)])

		# Introduce stronger enemies in later waves
		if current_wave > 5:
			var chance_black = 0.1 + (float(current_wave) / (total_waves if total_waves != -1 else 20.0))
			if randf() < chance_black:
				wave_data_to_spawn.append(["black_tank", randf_range(0.5, 1.5)])

		# Introduce even stronger enemies in even later waves
		if current_wave > 10:
			var chance_armored = 0.05 + (float(current_wave) / (total_waves if total_waves != -1 else 30.0))
			if randf() < chance_armored:
				wave_data_to_spawn.append(["armored_tank", randf_range(0.7, 2.0)])

	enemies_in_wave = num_to_spawn
	spawn_enemies(wave_data_to_spawn, num_to_spawn)

func spawn_enemies(enemies_to_spawn, count):
	var spawned_count = 0
	while spawned_count < count:
		for enemy_info in enemies_to_spawn:
			var enemy_scene_path = "res://" + enemy_info[0] + ".tscn"
			var spawn_delay = enemy_info[1]
			var enemy_scene = load(enemy_scene_path)

			if enemy_scene:
				var new_enemy = enemy_scene.instantiate()
				new_enemy.add_to_group("enemies") # Add to an 'enemies' group for tracking
				new_enemy.base_damage.connect(on_base_damage)
				map_node.get_node("Path").add_child(new_enemy, true)
				enemies_spawned_this_wave += 1
				await get_tree().create_timer(spawn_delay).timeout
				if enemies_spawned_this_wave >= count:
					break
			else:
				print("Error loading enemy scene:", enemy_scene_path)
		spawned_count = enemies_spawned_this_wave
		if spawned_count >= count:
			break

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
	if map_node.get_node("TowerExclusion").get_cell_source_id(current_tile) == -1 and 0 <= GameData.Gold - GameData.tower_data[build_type]["cost"]:
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
	## deduct cash
	var moneyDisplay = get_node("UI/HUD/UpperMenu/Money/MoneyIcon/Money")
	if 0 <= GameData.Gold - GameData.tower_data[build_type]["cost"]:
		
		if build_valid:
			var new_tower = load("res://" + build_type + ".tscn").instantiate()
			new_tower.position = build_location
			new_tower.built = true
			new_tower.type = build_type
			new_tower.category = GameData.tower_data[build_type]["category"]
			if new_tower.category == "Missile":
				new_tower.fire_ready = true
				new_tower.missile_1_ready = true
				new_tower.missile_2_ready = false
			map_node.get_node("turrets").add_child(new_tower, true)
			map_node.get_node("TowerExclusion").set_cell(build_tile, 1, Vector2i(1,0) ,0)
			
			## update cash label
			GameData.Gold -= GameData.tower_data[build_type]["cost"]
			moneyDisplay.text = str(GameData.Gold)

func on_base_damage(damage):
	base_health -= damage
	get_node("UI").update_health_bar(base_health)
	if base_health <= 0:
		emit_signal("game_finished", false)

func _on_game_finished(won):
	# 'won' will be false in this case (when base health is <= 0)
	print("Game Over! Redirecting to Main Menu.")
	get_tree().change_scene_to_file("res://scene_handeler.tscn") # Replace with your main menu scene path
	GameData.Gold = 100
