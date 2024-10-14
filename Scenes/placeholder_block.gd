extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Change the color of the child Sprite2D.
	# Color(1, 0.5, 0, 0) refers to (R, G, B, Alpha) in a range 0-1
	$Sprite2D.modulate = Color(1, 0.5, 0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
