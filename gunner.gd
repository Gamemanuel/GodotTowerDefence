extends "res://Turrets.gd"

func _ready() -> void:
	self.get_node("Turret/Muzzle/MuzzleFlash").visible = false
