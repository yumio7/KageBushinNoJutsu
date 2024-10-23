extends StaticBody2D
class_name VerticalMirror
# This vertical mirror will respond accordingly when the controlled character ability contacts it (kagerou dash, minamitsu grapple)

# Preload the characters for faster switching
var kagerouScene: PackedScene = preload("res://Scenes/Entities/kagerou.tscn")
var minamitsuScene: PackedScene = preload("res://Scenes/Entities/minamitsu.tscn")

# Track the current character instance for the switch stun
var trackedCharInstance = null

# charCurrent refers to the current character. All parameters are passed to this function by the controlled character
func mirrorSwitch(charPositionY, charVelocity, currentCharName):

	$SwapSFX.play()

    # Depending on the normal of the worldboundary, switch it
	if $CollisionShape2D.shape.normal == Vector2(-1, 0):
		$CollisionShape2D.shape.normal = Vector2(1, 0)
	elif $CollisionShape2D.shape.normal == Vector2(1, 0):
		$CollisionShape2D.shape.normal = Vector2(-1, 0)

	# Depending on who the charCurrent is, instantiate the other character at the proper position

	if currentCharName == "Kagerou":
		var minamitsuInstance = minamitsuScene.instantiate()
		minamitsuInstance.currentState = 5  # Set her to pause state temporarily. The switchStunTimer will switch her back to idle state afterwards
		$"../ControlledCharacter".add_child(minamitsuInstance)
		minamitsuInstance.position = Vector2(global_position.x, charPositionY)
		minamitsuInstance.velocity = Vector2(charVelocity, 0)
		trackedCharInstance = minamitsuInstance
	elif currentCharName == "Minamitsu":
		var kagerouInstance = kagerouScene.instantiate()
		kagerouInstance.currentState = 5 # Set her to pause state temporarily. The switchStunTimer will switch her back to idle state afterwards
		$"../ControlledCharacter".add_child(kagerouInstance)
		kagerouInstance.position = Vector2(global_position.x, charPositionY)
		kagerouInstance.velocity = Vector2(charVelocity, 0)
		trackedCharInstance = kagerouInstance

	# Start switchStunTimer
	$switchStunTimer.start()

func _on_switch_stun_timer_timeout() -> void:
	trackedCharInstance.currentState = 0 # Set her to idle state
