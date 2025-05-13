extends AnimatedSprite2D


func _on_animation_finished() -> void:
	print("done")
	queue_free()
