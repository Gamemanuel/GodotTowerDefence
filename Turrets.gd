extends Node2D

var type
var enemy_array = []
var built = false
var enemy
var fire_ready = true
var category

var visual_missiles = [] # To hold references to your two Sprite2D nodes
var missile_ready = [true, true] # Track if each visual missile is ready to fire
const MISSILE_SCENE = preload("res://Missile.tscn")
var reload_timer = [] # To track reload timers for each missile

func _ready() -> void:
	if built:
		print(type)
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]
		if is_instance_valid(get_node("Turret/Missile1")) and is_instance_valid(get_node("Turret/Missile2")):
			visual_missiles.append(get_node("Turret/Missile1")) # Get reference to Sprite1
			visual_missiles.append(get_node("Turret/Missile2")) # Get reference to Sprite2
			missile_ready = [true, true]
			reload_timer.append(null)
			reload_timer.append(null)
			# Initially, show both missiles
			if visual_missiles.size() == 2:
				visual_missiles[0].show()
				visual_missiles[1].show()
			# Start the continuous visual reload cycle
			_cycle_visual_reload()
		else:
			# this means that you are trying to hit a tank that has not been fully loaded and the error is regular
			printerr("Error: Ensure 'Turret/Missile1' and 'Turret/Missile2' nodes exist.")

func _physics_process(delta: float) -> void:
	if enemy_array.size() != 0 and built:
		select_enemy()
		if not get_node("AnimationPlayer").is_playing():
			turn()
		if fire_ready and enemy != null: # Only fire if there's a valid enemy
			fire()
	else:
		enemy = null

func turn():
	if enemy:
		get_node("Turret").look_at(enemy.global_position)

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
	get_node("AnimationPlayer").play("Fire")

	if category == "Projectile":
		fire_gun()
	elif category == "Missile":
		_fire_visual_missile()

	if is_instance_valid(enemy):
		enemy.on_hit(GameData.tower_data[type]["damage"])
	await get_tree().create_timer(GameData.tower_data[type]["rof"]).timeout
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
			reload_timer[fired_index] = get_tree().create_timer(GameData.tower_data[type]["rof"])
			reload_timer[fired_index].connect("timeout", Callable(self, "_on_reload_timeout").bind(fired_index))

func launch_missile():
	var missile_instance = load("res://Missile.tscn").instantiate()
	get_tree().current_scene.add_child(missile_instance)
	missile_instance.global_position = get_node("Turret").global_position
	if enemy and is_instance_valid(enemy) and missile_instance.has_method("launch"):
		missile_instance.launch(enemy.global_position, enemy, enemy.global_position)
	else:
		if not is_instance_valid(enemy):
			printerr("Error: No valid enemy to target.")
		elif not missile_instance.has_method("launch"):
			printerr("Error: Missile instance does not have a 'launch' function.")
		missile_instance.queue_free()

func fire_gun():
	get_node("AnimationPlayer").play("Fire")

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
			reload_timer[i] = get_tree().create_timer(GameData.tower_data[type]["rof"] * (i + 1) * 0.001) # Staggered reload
			reload_timer[i].connect("timeout", Callable(self, "_on_reload_timeout").bind(i))
