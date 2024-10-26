extends MarginContainer

@export_file var next_scene = "res://Scenes/mainmenu.gd"

func _on_visibility_changed() -> void:
	$VBoxContainer/Buttons/Continue.call_deferred("grab_focus")

func _on_continue_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(next_scene)


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
