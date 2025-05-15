extends PathFollow2D

signal base_damage(damage)

var speed = 0.1
var hp = 50
var baseDamage = 21

@onready var health_bar = get_node("HealthBar")
@onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://projectileImpact.tscn")

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.top_level = true

func _process(delta: float) -> void:
	if self.progress_ratio >= 1.0:
		emit_signal("base_damage", baseDamage)
		queue_free()
	move(delta)

func move(delta):
	progress_ratio += delta * speed
	health_bar.position = position - Vector2(30,35)

func on_hit(damage):
	impact()
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		on_destroy()

func impact():
	randomize()
	var x_pos = randi() % 31
	randomize()
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)
	
func on_destroy():
	get_node("CharacterBody2D").queue_free()
	await get_tree().create_timer(.2).timeout
	self.queue_free()
