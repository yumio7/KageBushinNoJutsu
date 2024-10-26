extends StaticBody2D
class_name BlockKagerou
# This block will break when hit by an ability (Dash, anchor)
# Additionally, it will also break its sister block in the reflection
# My idea is to have two "BlockContainer" node to contain all breakable blocks, assigned numbers
# I will copy this blockContainer node to the other side. It will then automatically break the sister block inside the copied blockContainer node

# Refers to the same-position block on the other side of the mirror
@export var mirroredForm: BlockKagerou = null
var canBreak = true # Failsafe in case onCollision triggers more than once

func onCollision():
	if canBreak:
		canBreak = false
		$CollisionShape2D.set_deferred("disabled", true)
		$AudioStreamPlayer2D.play()
		$AnimatedSprite2D.modulate = Color(3, 3, 3, 1)
		var modTween = create_tween()
		modTween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1, 0), .1)
		$DeathTimer.start()
		if mirroredForm != null:
			mirroredForm.onCollision()

# Play the animation
func _on_shine_timer_timeout() -> void:
	$AnimatedSprite2D.play("Shimmer")

func _on_death_timer_timeout() -> void:
	queue_free()
