extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("MainMenu/M/VB/NewGame").connect("pressed", Callable(self, "on_new_game_pressed"))
	get_node("MainMenu/M/VB/Quit").connect("pressed", Callable(self, "on_quit_pressed"))
	get_node("MainMenu/M/VB/about").connect("pressed", Callable(self, "on_about_pressed"))
	get_node("MainMenu/M/VB/Settings").connect("pressed", Callable(self, "on_settings_pressed"))

func on_new_game_pressed() -> void:
	get_node("MainMenu").queue_free()
	var game_scene = load("res://game_scene.tscn").instantiate()

	add_child(game_scene)

func on_quit_pressed() -> void:
	print("Game quitting")
	get_tree().quit()  # Quits the game

func on_about_pressed() -> void:
	print("Displaying about section")

func on_settings_pressed() -> void:
	print("Opening settings")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
