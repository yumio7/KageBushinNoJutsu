extends Node2D

var timer: int = 0;
var brighten: bool = false;

func _on_dialogue_end_dialogue() -> void:
	get_tree().change_scene_to_file("res://Scenes/RootScenes/level_1.tscn")

func _on_dialogue_dialogue_line_fired(currentLineIndex, lineArraySize) -> void:
	if currentLineIndex - (lineArraySize-1) == 0: # last line of dialogue fired
		brighten = true

func _process(_delta: float) -> void:
	if brighten:
		timer += 1
		$BrightenCanvasLayer/ColorRect.material.set_shader_parameter("colourAdd", (timer as float) / 100)
		$BrightenCanvasLayer/ColorRect.material.set_shader_parameter("multiplier", 1.0 + (timer as float) / 30)
		if timer >= 100:
			get_tree().change_scene_to_file("res://Scenes/RootScenes/level_1.tscn")