extends PathFollow2D

var speed = 0.1
var hp = 50

@onready var health_bar = get_node("HealthBar")
func _ready():
	
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.top_level = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)

func move(delta):
	progress_ratio += delta * speed
	health_bar.position = position - Vector2(30,35)

func on_hit(damage):
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		on_destroy()
		
func on_destroy():
	self.queue_free()
