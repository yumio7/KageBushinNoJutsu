extends CharacterBody2D
# TODO (If possible)
# Coyote time
# Jump buffer
# Variant jump height depending on how long the jump input is held

# Constants. Assigned values cannot be changed
const walkSpeed: float = 40.0			# Base walking Movement speed
const walkSpeedMax: float = 100.0		# Maximum walking movement speed. Minamitsu cannot move faster than this when walking.
const jumpVelocity: float = -210.0		# Jump velocity. It is negative because in Godot up is negative y.
const fallSpeedMax: float = 200.0		# Maximum fall velocity. Minamitsu cannot fall faster than this.
const anchorVelocity: float = 300.0		# Velocity at which the anchor flies through the air
const grappleVelocity: float = 500.0	# Velocity at which Minamitsu is pulled to the anchor
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Tracks state of character for different movement behaviours
enum state {Idle = 0, Walk = 1, Jump = 2, Fall = 3, Ability = 4, Pause = 5, Grapple = 6}		# Define enum for every state
var currentState: int = state.Idle																# Tracks the current state. By default, it is set to idle.
var walkDirection = 0																			# Keep track of whether controls for walking are being held down
var previousFloorState = false																	# Tracks the previous grounded state of player. Used for Coyote Time
var tweenSound																					# Declare a potential tween which modifies sound
var anchorProjectile = preload("res://Scenes/Entities/anchor_projectile.tscn")					# Preload the anchor projectile for faster instantiation
var anchorProjectileInstance = null																# Track the anchorProjectile instance's location and status
var grappledMirrorFlag = false																	# Track whether minamitsu is currently grappling into the mirror
var anchorHitObject	= null																		# Track the anchor's hit object
var directionToAnchor = 0																		# Track the direction minamitsu faces when yeeting anchor

# Runs once when the character is instantiated
func _ready() -> void:
	pass # Nothing happens here for now

# Runs every physics frame (60fps)
func _physics_process(delta: float) -> void:
	
	#print("0-" + str(currentState)) # FOR DEBUGGING: Print the current state before all physics logic executes

	var directionToThrow = 1 # Store the directionToThrow in wide scope for the stateAbility() function
	if $AnimatedSprite2D.flip_h == true: directionToThrow = -1
	else: directionToThrow = 1

	# Throw/Grapple ability. Sets the state to ability and yeet anchor
	if currentState != state.Ability and currentState != state.Pause and currentState != state.Grapple and Input.is_action_just_pressed("Ability") and $Timers/AnchorCooldown.time_left <= 0:
		currentState = state.Ability
		velocity = Vector2(0, 0)
		$Timers/AnchorLimit.start()
		$Sounds/AnchorThrowSFX.play()

		# Create instance of anchor and attaches the velocity (Depends on where character faces) and character node to it.
		anchorProjectileInstance = anchorProjectile.instantiate()
		anchorProjectileInstance.throwVelocity = anchorVelocity * directionToThrow
		anchorProjectileInstance.trackedPlayer = $"."	# References the current node the script is attached to (CharacterBody2D named Minamitsu)
		anchorProjectileInstance.body_entered.connect(anchorHit) # Connect anchor's body_entered signal to function, so minamitsu can respond to what the anchor hits
		anchorProjectileInstance.tree_exiting.connect(anchorRemoval) # Make sure that Minamitsu can respond to anchor exitting the tree
		$"..".add_child(anchorProjectileInstance)		# Sets the anchor instance's parent to the parent node (SHOULD BE ENTITIES NODE2D IN LEVEL)
		anchorProjectileInstance.position = $AnchorStartPos.global_position	#AnchorStartPos is a node2D child under minamitsu which is slightly offset in front of her
		

	# If the user is using an ability, lock all other movement
	if currentState != state.Ability and currentState != state.Pause and currentState != state.Grapple:
		# Check if player is holding down movement control. Move them if yes.
		walkDirection = Input.get_axis("Left", "Right")
		# Track if user is making walking input and moves character in that direction.
		if walkDirection and abs(velocity.x) < walkSpeedMax: velocity.x += walkDirection * walkSpeed
		elif walkDirection and abs(velocity.x) > walkSpeedMax: velocity.x = walkSpeedMax * walkDirection
		else: velocity.x = move_toward(velocity.x, 0, walkSpeed)
		
		# Determine if the player can jump with this variable
		var canJump = false
		# Determine if coyote time is allowed by comparing previous floor state with current ground state
		if !is_on_floor() and previousFloorState == true: $Timers/JumpCoyoteTime.start()
		previousFloorState = is_on_floor() # Update the previous floor state after check

		# Check if player is inputting jump. Depending on how long they input, their jump height will change
		if Input.is_action_just_pressed("Jump") and is_on_floor(): canJump = true
		# Jump buffer timer starts when player jumps but is not on floor
		elif Input.is_action_just_pressed("Jump") and !is_on_floor() and $Timers/JumpCoyoteTime.time_left == 0: $Timers/JumpBuffer.start()
		# If jump buffer timer is on and player lands, they jump
		elif Input.is_action_pressed("Jump") and is_on_floor() and $Timers/JumpBuffer.time_left > 0: canJump = true
		# If coyote time is on and player jumps, they jump
		elif Input.is_action_just_pressed("Jump") and !is_on_floor() and $Timers/JumpCoyoteTime.time_left > 0: canJump = true
		# Depending on length of input, jump height increases
		elif Input.is_action_pressed("Jump") and !is_on_floor() and $Timers/JumpHeightTimer.time_left > 0: velocity.y = jumpVelocity
		# Edge case in case the player releases&inputs again when JumpHeightTimer is on.
		elif Input.is_action_just_released("Jump") and $Timers/JumpHeightTimer.time_left > 0:
			$Timers/JumpHeightTimer.stop()
			tweenSound = create_tween()
			tweenSound.tween_property($Sounds/JumpSFX, "volume_db", -30, .5)
			tweenSound.tween_callback(resetJumpSFX)

		if canJump == true:
			if tweenSound: tweenSound.kill()
			resetJumpSFX()
			$Sounds/JumpSFX.play()
			$Timers/JumpHeightTimer.start()
			velocity.y = jumpVelocity

		# Dictate state depending on the physics of the character.
		if is_on_floor() and velocity.x == 0:
			currentState = state.Idle
		elif is_on_floor() and velocity.x != 0: currentState = state.Walk
		elif !is_on_floor() and velocity.y >= 0: currentState = state.Fall
		elif !is_on_floor() and velocity.y < 0: currentState = state.Jump

	# State machine. Depending on the currentState, run a different function with different movement behaviour
	match currentState:
		0: stateIdle()
		1: stateWalk()
		2: stateJump(delta)
		3: stateFall(delta)
		4: stateAbility()
		5: statePause(delta)
		6: stateGrapple()

	#print("1-" + str(currentState)) # FOR DEBUGGING: Print the current state after all physics logic executes

	# Flip sprite depending on horizontal velocity, additionally set the anchorStartPosition to the other side
	if walkDirection > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.offset.x = 0
		$Anchor.flip_h = true
		$AnchorStartPos.position.x = 4
	elif walkDirection < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.offset.x = 3
		$Anchor.flip_h = false
		$AnchorStartPos.position.x = -4

	# Character will slide along surfaces when moving
	move_and_slide()

# Anchor tween
func anchorTweener(posY, rotDeg):
	if $AnimatedSprite2D.flip_h == true: rotDeg = rotDeg * -1

	if $Anchor.position.y != posY:
		var anchorTween = $Anchor.create_tween()
		anchorTween.tween_property($Anchor, "position", Vector2(0, posY), .2)
		anchorTween.parallel().tween_property($Anchor, "rotation_degrees", rotDeg, .2)

# Specific behaviours for each state
func stateIdle():
	$AnimatedSprite2D.play("Idle")
	anchorTweener(-5, 0)
	
func stateWalk():
	$AnimatedSprite2D.play("Walk")
	anchorTweener(-5, 0)

func stateJump(delta):
	$AnimatedSprite2D.play("Jump")
	anchorTweener(-4, -15)

	applyGravity(delta) # Gravity

func stateFall(delta):
	$AnimatedSprite2D.play("Fall")
	anchorTweener(-12, 15)

	applyGravity(delta) # Gravity
	
func stateAbility():
	$Anchor.visible = false
	$AnimatedSprite2D.play("Jump")

# During a paused state, the character will still be affected by gravity and will play an idle animation
func statePause(delta):
	$AnimatedSprite2D.play("Idle")
	applyGravity(delta) # Gravity

# Move minamitsu towards the anchor until she stops or gets near enough to it
func stateGrapple():
	$Anchor.visible = false
	$AnimatedSprite2D.play("Fall")
	directionToAnchor = position.direction_to(anchorProjectileInstance.global_position)
	var distanceToAnchor = position.distance_to(anchorProjectileInstance.global_position)
	velocity = directionToAnchor * grappleVelocity
	if distanceToAnchor < 10:
		anchorCancel()


# Function to apply gravity
func applyGravity(delta):
	# Apply gravity to vertical velocity until max falling speed reached
	if not is_on_floor() and velocity.y < fallSpeedMax:
		velocity.y += gravity * delta

# When the player releases jump button and sound volume is tweened out, this function will reset volume
func resetJumpSFX():
	$Sounds/JumpSFX.stop()
	$Sounds/JumpSFX.volume_db = 10

func _on_dash_duration_timeout():
	currentState = state.Idle

# When the anchor times out
func _on_anchor_limit_timeout() -> void:
	anchorCancel()

# When the anchor projectile hits appropriate body
func anchorHit(body):
	
	# ONLY PROCEED IF THE ANCHOR EXISTS AND ITS STATE IS ACTIVE (0)
	if anchorProjectileInstance != null and anchorProjectileInstance.currentState == 0:
		
		var anchorCollideEnvironmentTileMap = 0
		var anchorCollideEnvironment = false
		var anchorCollideInteractible = false

		# Depending on if the hit body's collision layer (Environment or interactible), the anchor should perform different actions
		if body is TileMapLayer:
			anchorCollideEnvironmentTileMap = body.tile_set.get_physics_layer_collision_layer(0)
		else:
			anchorCollideEnvironment = body.get_collision_layer_value(2)
			anchorCollideInteractible = body.get_collision_layer_value(3)
		# If the layer is 2 (Environment), always attach the anchor and grapple minamitsu toward it
		if anchorCollideEnvironment == true or anchorCollideEnvironmentTileMap == 2:
			$Timers/AnchorLimit.stop()
			anchorProjectileInstance.currentState = 1 # This sets anchor to an attached (1) state. This is ugly but it works
			currentState = state.Grapple
			$Timers/GrappleLimit.start()
		# If the layer is 3 (Interactible), the anchor will check what type of interactible it is and either attach (Barrier) or break it (Breakable Block)
		if anchorCollideInteractible:
			match body.name:
				"VerticalMirror":
					$Timers/AnchorLimit.stop()
					anchorProjectileInstance.currentState = 1
					currentState = state.Grapple
					$Timers/GrappleLimit.start()
					grappledMirrorFlag = true
					anchorHitObject = body


# Function to end minamitsu's ability by retracting anchor and removing it. Acts differently when minamitsu grapples the mirror
func anchorCancel():

	if grappledMirrorFlag == false:
		$Timers/AnchorLimit.stop()
		$Timers/GrappleLimit.stop()
		currentState = state.Idle
		anchorProjectileInstance.currentState = 2 # This sets anchor to a retracting (2) state. This is ugly but if it works it works
		$Timers/AnchorCooldown.start()
	elif grappledMirrorFlag == true:
		if anchorProjectileInstance != null:
			anchorProjectileInstance.queue_free()
		anchorHitObject.mirrorSwitch(global_position.y, grappleVelocity * directionToAnchor.x, name)
		queue_free()


# Function to track when the anchor disappears
func anchorRemoval():
	$Anchor.visible = true
	anchorProjectileInstance = null

# In case minamitsu takes too long to grapple (Because she is stuck)
func _on_grapple_limit_timeout() -> void:
	grappledMirrorFlag = false
	anchorCancel()

# Function to set camera limits
func setCameraLimits(left, right, bottom, top, newOffset):
	$Camera2D.limit_left = left
	$Camera2D.limit_right = right
	$Camera2D.limit_bottom = bottom
	$Camera2D.limit_top = top
	$Camera2D.offset = newOffset
