extends PathFollow2D

var speed = 0.1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)

func move(delta):
	progress_ratio += delta * speed
