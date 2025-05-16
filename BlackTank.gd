extends "res://enemies.gd"

func _ready():
	# bot config
	speed = 0.1
	hp = 100
	baseDamage = 25
	kill_reward = 10 # Cash awarded on kill
	
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.top_level = true
	loaded = true # Tank is loaded when _ready is finished
