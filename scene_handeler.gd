extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_main_menu()

func load_main_menu():
	var main_menu = get_node_or_null("MainMenu")
	if main_menu:
		var new_game_button = main_menu.get_node_or_null("M/VB/NewGame")
		var quit_button = main_menu.get_node_or_null("M/VB/Quit")
		var about_button = main_menu.get_node_or_null("M/VB/About")
		var settings_button = main_menu.get_node_or_null("M/VB/Settings")
		
		

		if new_game_button:
			new_game_button.connect("pressed", Callable(self, "on_new_game_pressed"))
		if quit_button:
			quit_button.connect("pressed", Callable(self, "on_quit_pressed"))
		if about_button:
			about_button.connect("pressed", Callable(self, "on_about_pressed"))
		if settings_button:
			settings_button.connect("pressed", Callable(self, "on_settings_pressed"))
			

func on_new_game_pressed() -> void:
	print("new game")
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

func unload_game(result):
	print("entered")
	var game_scene = get_node("GameScene")
	game_scene.queue_free()

	var main_menu = load("res://main_menu.tscn").instantiate()
	add_child(main_menu)
	
	print("Main menu added!")  # Debugging: See if it's actually added
	load_main_menu()
