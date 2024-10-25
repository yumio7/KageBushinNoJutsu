extends StaticBody2D
class_name Block
# This block will break when hit by an ability (Dash, anchor)
# Additionally, it will also break its sister block in the reflection
# My idea is to have two "BlockContainer" node to contain all breakable blocks, assigned numbers
# I will copy this blockContainer node to the other side. It will then automatically break the sister block inside the copied blockContainer node

func onCollision(_delta):
	$CollisionShape2D.disabled = true
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.modulate = Color(0, 0, 0, 0)
	$DeathTimer.start()

# Play the animation
func _on_shine_timer_timeout() -> void:
	$AnimatedSprite2D.play("Shimmer")

func _on_death_timer_timeout() -> void:
	queue_free()
