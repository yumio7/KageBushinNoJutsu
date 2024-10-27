extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/MenuButtons/play.call_deferred("grab_focus")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/intro.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/credits.tscn")

func _on_music_finished() -> void:
	$Ambience.play()

func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/level_select.tscn")
