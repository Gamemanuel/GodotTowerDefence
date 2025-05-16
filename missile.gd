extends CharacterBody2D

var speed = 1200
var missile_velocity = Vector2.ZERO
var target_node
var last_target_position = Vector2.ZERO
var state = "FLYING"

func launch(target_position, target, current_target_position: Vector2):
	target_node = target
	last_target_position = current_target_position
	state = "FLYING"
	if is_instance_valid(target_node):
		var target_character_body = target_node.get_node("CharacterBody2D") # Get the CharacterBody2D
		if is_instance_valid(target_character_body) and target_character_body.has_node("CollisionShape2D"):
			var collision_shape = target_character_body.get_node("CollisionShape2D")
			target_character_body.area_entered.connect(_on_target_body_entered)
			print("Successfully connected to CollisionShape2D")
		else:
			printerr("Error: Could not find CharacterBody2D or its CollisionShape2D.")
	else:
		printerr("Error: Target (PathFollow2D) is not valid.")

func _physics_process(delta):
	if state == "FLYING":
		if is_instance_valid(target_node):
			var current_target_pos = target_node.global_position
			var target_velocity = (current_target_pos - last_target_position) / delta if delta > 0 else Vector2.ZERO
			last_target_position = current_target_pos

			# Reduced prediction sensitivity
			var prediction_time = global_position.distance_to(current_target_pos) / speed * 0.2 # Reduced multiplier
			var predicted_position = current_target_pos + (target_velocity * prediction_time)
			var desired_velocity = (predicted_position - global_position).normalized() * speed

			# Directly set velocity for now, we can add smoothing later if needed
			missile_velocity = desired_velocity
			rotation = missile_velocity.angle()
			velocity = missile_velocity
			move_and_slide()
		else:
			queue_free()
	elif state == "IMPACTED":
		velocity = Vector2.ZERO # Stop movement immediately
		move_and_slide()
		set_physics_process(false)
		set_process(false)

func _on_target_body_entered(body):
	if state == "FLYING": # Check if the entering body is the missile
		state = "IMPACTED"
		queue_free()
