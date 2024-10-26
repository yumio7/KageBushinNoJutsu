extends MarginContainer

func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_visibility_changed() -> void:
	$VBoxContainer/Buttons/Resume.call_deferred("grab_focus")

func _on_settings_pressed() -> void:
	#TODO: implement settings menu
	pass # Replace with function body.

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
