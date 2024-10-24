extends StaticBody2D
class_name VerticalMirror
# This vertical mirror will respond accordingly when the controlled character ability contacts it (kagerou dash, minamitsu grapple)

# Mirror dimensions
const mirrorBaseUpPoint: Vector2 = Vector2(0, 0)

# SET THIS OR ELSE CAMERA FUNCTIONALITY MIGHT BE BUGGY
@export var starterCharacter: CharacterBody2D = null
@export var cameraSettingComponent: Node = null
var camLimTop = -1000000
var camLimBottom = 1000000
var camLimRight = 1000000
var camLimLeft = -1000000
var camNewOffset = Vector2(0, 0)

# Preload the characters for faster switching
var kagerouScene: PackedScene = preload("res://Scenes/Entities/kagerou.tscn")
var minamitsuScene: PackedScene = preload("res://Scenes/Entities/minamitsu.tscn")

# Track the current character instance for the switch stun
var trackedCharInstance = null

# Set the camera settings for the character
func _ready() -> void:
	if starterCharacter != null: trackedCharInstance = starterCharacter
	if cameraSettingComponent != null:
		camLimLeft = cameraSettingComponent.limitLeft
		camLimRight = cameraSettingComponent.limitRight
		camLimBottom = cameraSettingComponent.limitBottom
		camLimTop = cameraSettingComponent.limitTop
		camNewOffset = cameraSettingComponent.newOffset

	trackedCharInstance.setCameraLimits(camLimLeft, camLimRight, camLimBottom, camLimTop, camNewOffset)

# Update the mirror drawing to match the player
func _physics_process(delta: float) -> void:
	pass


# charCurrent refers to the current character. All parameters are passed to this function by the controlled character
func mirrorSwitch(charPositionY, charVelocity, currentCharName):

	$SwapSFX.play()

	# Depending on the normal of the worldboundary, switch it. Change direction character is facing if applicable
	var swapDirection = false
	if $CollisionShape2D.shape.normal == Vector2(-1, 0):
		$CollisionShape2D.shape.normal = Vector2(1, 0)
	elif $CollisionShape2D.shape.normal == Vector2(1, 0):
		$CollisionShape2D.shape.normal = Vector2(-1, 0)
		swapDirection = true

	# Depending on who the charCurrent is, instantiate the other character at the proper position

	if currentCharName == "Kagerou":
		var minamitsuInstance = minamitsuScene.instantiate()
		minamitsuInstance.currentState = 5  # Set her to pause state temporarily. The switchStunTimer will switch her back to idle state afterwards
		$"../ControlledCharacter".add_child(minamitsuInstance)
		minamitsuInstance.position = Vector2(global_position.x, charPositionY)
		minamitsuInstance.velocity = Vector2(charVelocity, 0)
		minamitsuInstance.find_child("AnimatedSprite2D").flip_h = swapDirection
		trackedCharInstance = minamitsuInstance
		trackedCharInstance.setCameraLimits(camLimLeft, camLimRight, camLimBottom, camLimTop, camNewOffset)
	elif currentCharName == "Minamitsu":
		var kagerouInstance = kagerouScene.instantiate()
		kagerouInstance.currentState = 5 # Set her to pause state temporarily. The switchStunTimer will switch her back to idle state afterwards
		$"../ControlledCharacter".add_child(kagerouInstance)
		kagerouInstance.position = Vector2(global_position.x, charPositionY)
		kagerouInstance.velocity = Vector2(charVelocity, 0)
		kagerouInstance.find_child("AnimatedSprite2D").flip_h = swapDirection
		trackedCharInstance = kagerouInstance
		trackedCharInstance.setCameraLimits(camLimLeft, camLimRight, camLimBottom, camLimTop, camNewOffset)

	# Start switchStunTimer
	$switchStunTimer.start()

func _on_switch_stun_timer_timeout() -> void:
	trackedCharInstance.currentState = 0 # Set her to idle state
