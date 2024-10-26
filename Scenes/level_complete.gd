extends MarginContainer

@export_file var next_scene = "res://Scenes/mainmenu.gd"

func _on_level_end() -> void:
	show()
	get_tree().paused = true
	$VBoxContainer/Buttons/Continue.call_deferred("grab_focus")
	
func _on_continue_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(next_scene)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
