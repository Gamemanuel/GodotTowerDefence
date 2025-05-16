extends "res://Turrets.gd"


func _ready() -> void:
	power = GameData.tower_data["GunT1"]["damage"]
	range = GameData.tower_data["GunT1"]["range"]
	rof = GameData.tower_data["GunT1"]["rof"]

	# helper variables for upgrades
	powerIncrease = .5
	PowerIncreaseCost = 20
	rangeIncrease = .5
	rangeIncreaseCost = 20
	rofIncrease = .05
	rofIncreaseCost = 20
	sellCost = 20

	self.get_node("Turret/Muzzle/MuzzleFlash").visible = false
	get_node("Upgrade/Upgrade").global_position = self.position + Vector2(-140,40)
	get_node("Upgrade/Upgrade/HBoxContainer/power/Cost").text = str(PowerIncreaseCost)
	get_node("Upgrade/Upgrade/HBoxContainer/range/Cost").text = str(rangeIncreaseCost)
	get_node("Upgrade/Upgrade/HBoxContainer/rof/Cost").text = str(rofIncreaseCost)
	get_node("Upgrade/Upgrade/HBoxContainer/sell/Cost").text = str(sellCost)
	print(power)
	print(range)
	print(rof)
	

	if built:
		print(type)
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * range
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
