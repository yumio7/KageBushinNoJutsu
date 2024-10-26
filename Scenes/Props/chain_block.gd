extends StaticBody2D
class_name ChainBlock
# Breaks in a sequence when attached to a breakable block's chainBlockArray
# I am not setting this sequence manually even if it kills me, so a hacky automated system should work for this

var canBreak = true # Failsafe in case onCollision triggers more than once

func breakBlock():
	if canBreak:
		canBreak = false
		$CollisionShape2D.set_deferred("disabled", true)
		$AudioStreamPlayer2D.play()
		$Sprite2D.modulate = Color(3, 3, 3, 1)
		var modTween = create_tween()
		modTween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), .1)

func _on_death_timer_timeout() -> void:
	queue_free()
