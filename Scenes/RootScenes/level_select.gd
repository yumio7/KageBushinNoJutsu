extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/MenuButtons/level1.call_deferred("grab_focus")

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/level_1.tscn")


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/level_2.tscn")


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/level_3.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
