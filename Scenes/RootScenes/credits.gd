extends TextureRect

func _ready() -> void:
	$VBoxContainer/HBoxContainer/VBoxContainer2/Menu.call_deferred("grab_focus")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")