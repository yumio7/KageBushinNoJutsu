extends StaticBody2D
class_name BlockKagerou
# This block will break when hit by an ability (Dash, anchor)
# Additionally, it will also break its sister block in the reflection
# My idea is to have two "BlockContainer" node to contain all breakable blocks, assigned numbers
# I will copy this blockContainer node to the other side. It will then automatically break the sister block inside the copied blockContainer node

@export var mirroredForm: BlockKagerou = null		# Refers to the same-position block on the other side of the mirror
@export var chainBlockArray: Array[ChainBlock] = []	# Refers to an array containing connected chain blocks
var chainBlockArrayCounter = 0						# Counts the indices in the chainBlockArray
var canBreak = true # Failsafe in case onCollision triggers more than once

func onCollision():

	# If statement prevents infinitely recursive loop from calling onCollision function in mirroredForm block
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

		# If the chainBlockArray > 0, activate a timer that breaks all chain blocks in array
		if chainBlockArray.size() > 0:
			$ChainBlockBreakDelay.start()

# Play the animation
func _on_shine_timer_timeout() -> void:
	$AnimatedSprite2D.play("Shimmer")

func _on_death_timer_timeout() -> void:
	queue_free()


func _on_chain_block_break_delay_timeout() -> void:
	if chainBlockArrayCounter < chainBlockArray.size():
		chainBlockArray[chainBlockArrayCounter].breakBlock()
		chainBlockArrayCounter += 1
	else:
		$ChainBlockBreakDelay.stop()
