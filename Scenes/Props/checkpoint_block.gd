extends StaticBody2D
class_name BlockCheckpoint

# Sets checkpoint for the player when hit with ability

@export var mirroredForm: BlockCheckpoint = null    # Sighhh gotta fix this so that we don't have to set the mirrored form manually...
@export var makeFloor = true                        # Determines whether to instantiate a checkpoint floor under the block when activated
var checkpointFloorScene: PackedScene = preload("res://Scenes/Props/checkpoint_floor.tscn")
var blockActivated = false  # Whether the block has been activated

# When collided with using ability, the checkpoint will activate.
func onCollision():
	if blockActivated == false:
		blockActivated = true
		$ShineTimer.stop()
		$AnimatedSprite2D.play("Activated")
		$AudioStreamPlayer2D.play()


		if makeFloor:
			var checkpointFloorInstance = checkpointFloorScene.instantiate()
			checkpointFloorInstance.position = $FloorSpawnPoint.position
			call_deferred("add_child", checkpointFloorInstance)

		if mirroredForm != null:
			mirroredForm.onCollision()
        

func _on_shine_timer_timeout() -> void:
	$AnimatedSprite2D.play("Shimmer")
