extends Node2D

func _on_dialogue_start_dialogue() -> void:
	process_mode = PROCESS_MODE_DISABLED


func _on_dialogue_end_dialogue() -> void:
	process_mode = PROCESS_MODE_INHERIT
