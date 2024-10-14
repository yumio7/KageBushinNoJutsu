extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/VBoxContainer/MenuButtons/play.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/testlevel.tscn")
	# TODO: play should boot to level select

func _on_settings_pressed() -> void:
	pass
	# TODO: will load to settings menu

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	pass
	# TODO: will change to credits scene, or open a popup on top of the main menu
