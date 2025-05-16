extends Node2D

var type
var enemy_array = []
var built = false
var enemy
var fire_ready = true
var category

var power = GameData.tower_data["GunT1"]["damage"]
var range = GameData.tower_data["GunT1"]["range"]
var rof = GameData.tower_data["GunT1"]["rof"]

var powerIncrease = 20
var PowerIncreaseCost = 20
var rangeIncrease = 20
var rangeIncreaseCost = 20
var rofIncrease = 20
var rofIncreaseCost = 20
var sellCost = 20

var visual_missiles = [] # To hold references to your two Sprite2D nodes
var missile_ready = [true, true] # Track if each visual missile is ready to fire
const MISSILE_SCENE = preload("res://Missile.tscn")
var reload_timer = [] # To track reload timers for each missile

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var turret: Node2D = get_node("Turret")
@onready var range_collision_shape: CollisionShape2D = get_node("Range/CollisionShape2D")

func _physics_process(delta: float) -> void:
	if enemy_array.size() != 0 and built:
		select_enemy()
		if not animation_player.is_playing():
			turn()
		if fire_ready and enemy != null: # Only fire if there's a valid enemy
			fire()
	else:
		enemy = null

func turn():
	if enemy:
		turret.look_at(enemy.global_position)

func select_enemy():
	if enemy_array.size() == 0:
		enemy = null
		return

	var closest_enemy = null
	var min_distance = INF

	for e in enemy_array:
		# Check if the enemy is valid and loaded
		if is_instance_valid(e) and "loaded" in e and e.loaded:
			var distance = e.global_position.distance_to(global_position)
			if distance < min_distance:
				closest_enemy = e
				min_distance = distance

	enemy = closest_enemy

func fire():
	fire_ready = false
	animation_player.play("Fire")

	if category == "Projectile":
		fire_gun()
	elif category == "Missile":
		_fire_visual_missile()

	if is_instance_valid(enemy):
		enemy.on_hit(power)
	await get_tree().create_timer(rof).timeout
	fire_ready = true

func _on_reload_timeout(missile_index):
	if is_instance_valid(visual_missiles[missile_index]):
		visual_missiles[missile_index].show()
		missile_ready[missile_index] = true
		reload_timer[missile_index] = null

func _fire_visual_missile():
	var fired_index = -1
	if missile_ready[0]:
		fired_index = 0
	elif missile_ready[1]:
		fired_index = 1

	if fired_index != -1:
		missile_ready[fired_index] = false
		if is_instance_valid(visual_missiles[fired_index]):
			visual_missiles[fired_index].hide()
			launch_missile() # Launch the actual projectile
			reload_timer[fired_index] = get_tree().create_timer(rof)
			reload_timer[fired_index].connect("timeout", Callable(self, "_on_reload_timeout").bind(fired_index))

func launch_missile():
	var missile_instance = load("res://Missile.tscn").instantiate()
	get_tree().current_scene.add_child(missile_instance)
	missile_instance.global_position = turret.global_position
	if enemy and is_instance_valid(enemy) and missile_instance.has_method("launch"):
		missile_instance.launch(enemy.global_position, enemy, enemy.global_position)
	else:
		if not is_instance_valid(enemy):
			printerr("Error: No valid enemy to target.")
		elif not missile_instance.has_method("launch"):
			printerr("Error: Missile instance does not have a 'launch' function.")
		missile_instance.queue_free()

func fire_gun():
	animation_player.play("Fire")

func _on_range_body_entered(body) -> void:
	var parent = body.get_parent()
	if is_instance_valid(parent):
		enemy_array.append(parent)
		print(enemy_array)

func _on_range_body_exited(body) -> void:
	var parent = body.get_parent()
	if is_instance_valid(parent):
		enemy_array.erase(parent)

func _cycle_visual_reload():
	if not built or visual_missiles.size() != 2:
		return

	for i in range(visual_missiles.size()):
		if is_instance_valid(visual_missiles[i]) and not missile_ready[i] and reload_timer[i] == null:
			reload_timer[i] = get_tree().create_timer(rof * (i + 1) * 0.001) # Staggered reload
			reload_timer[i].connect("timeout", Callable(self, "_on_reload_timeout").bind(i))

func _on_range_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 1:
		var map1 = get_parent().get_parent()
		if map1:
			var towerPath_alt = map1.get_node("turrets")
			if towerPath_alt:
				# Hide upgrade UI of all other turrets
				for i in towerPath_alt.get_child_count():
					var child = towerPath_alt.get_child(i)
					if child != self and child.has_node("Upgrade/Upgrade"):
						child.get_node("Upgrade/Upgrade").hide()
			else:
				printerr("Error: turrets node not found under Map1")
				return

			# Toggle the visibility of the current turret's upgrade UI
			if has_node("Upgrade/Upgrade"):
				var upgrade_node = get_node("Upgrade/Upgrade")
				upgrade_node.visible = !upgrade_node.visible
			else:
				printerr("Error: This turret does not have an 'Upgrade/Upgrade' node.")
		else:
			printerr("Error: Could not go up to Map1")

func _on_power_pressed() -> void:
	if GameData.Gold >= PowerIncreaseCost:
		GameData.Gold -= PowerIncreaseCost
		power += powerIncrease
		print(power)

func _on_range_pressed() -> void:
	if GameData.Gold >= rangeIncreaseCost:
		GameData.Gold -= rangeIncreaseCost
		range += rangeIncrease
		range_collision_shape.get_shape().radius = 0.5 * range
		print(range)

func _on_rof_pressed() -> void:
	if GameData.Gold >= rofIncreaseCost:
		GameData.Gold -= rofIncreaseCost
		if rof - rofIncrease == 0:
			rof = 0
		else:
			rof -= rofIncrease
		print(rof)

func _on_sell_pressed() -> void:
	GameData.Gold += sellCost
	var map1 = get_parent().get_parent()
	if map1:
		var tower_exclusion = map1.get_node("TowerExclusion")
		if tower_exclusion is TileMapLayer:
			var tile_set = tower_exclusion.tile_set
			if tile_set:
				var cell_size = tile_set.tile_size
				var map_coords = Vector2i(
					floor(global_position.x / cell_size.x),
					floor(global_position.y / cell_size.y)
				)
				tower_exclusion.set_cell(map_coords, -1)
				print("Erased tile at:", map_coords)
				queue_free()

func _on_power_mouse_entered() -> void:
	pass # Replace with function body.

func _on_power_mouse_exited() -> void:
	pass # Replace with function body.
