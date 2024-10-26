extends CanvasLayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		$PauseMenu.show()