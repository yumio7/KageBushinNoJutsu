extends Node2D

func _on_dialogue_end_dialogue() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/level_1.tscn")
