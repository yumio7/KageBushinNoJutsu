extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/MenuButtons/play.call_deferred("grab_focus")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/intro.tscn")
	# TODO: play should boot to level select

func _on_settings_pressed() -> void:
	pass
	# TODO: will load to settings menu

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	pass
	# TODO: will change to credits scene, or open a popup on top of the main menu

func _on_music_finished() -> void:
	$Ambience.play()
