extends CharacterBody2D
# TODO (If possible)
# Coyote time
# Jump buffer
# Variant jump height depending on how long the jump input is held

# Constants. Assigned values cannot be changed
const walkSpeed: float = 50.0			# Base walking Movement speed
const walkSpeedMax: float = 125.0		# Maximum walking movement speed. Kagerou cannot move faster than this when walking.
const jumpVelocity: float = -175.0		# Jump velocity. It is negative because in Godot up is negative y.
const fallSpeedMax: float = 200.0		# Maximum fall velocity. Kagerou cannot fall faster than this.
const dashVelocity: float = 250.0		# Dash velocity.
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Tracks state of character for different movement behaviours
enum state {Idle = 0, Walk = 1, Jump = 2, Fall = 3, Ability = 4}	# Define enum for every state
var currentState: int = state.Idle									# Tracks the current state. By default, it is set to idle.
var walkDirection = 0												# Keep track of whether controls for walking are being held down
var previousFloorState = false										# Tracks the previous grounded state of player. Used for Coyote Time

# Runs once when the character is instantiated
func _ready() -> void:
	pass # Nothing happens here for now

# Runs every physics frame (60fps)
func _physics_process(delta: float) -> void:
	
	#print("0-" + str(currentState)) # FOR DEBUGGING: Print the current state before all physics logic executes

	# Dash ability. Sets the state to ability and sets velocity
	if Input.is_action_just_pressed("Ability") and $Timers/DashCooldown.time_left <= 0:
		currentState = state.Ability
		var directionToDash = 1
		if $AnimatedSprite2D.flip_h == true: directionToDash = -1
		else: directionToDash = 1
		velocity = Vector2(dashVelocity * directionToDash, 0)
		$Timers/DashDuration.start()
		$Timers/DashCooldown.start()
	# If the user is using an ability, lock all other movement
	if currentState != state.Ability:
		# Check if player is holding down movement control. Move them if yes.
		walkDirection = Input.get_axis("Left", "Right")
		# Track if user is making walking input and moves character in that direction.
		if walkDirection and abs(velocity.x) < walkSpeedMax:
			velocity.x += walkDirection * walkSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, walkSpeed)
		
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
		elif Input.is_action_just_released("Jump"): $Timers/JumpHeightTimer.stop()

		if canJump == true:
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

	#print("1-" + str(currentState)) # FOR DEBUGGING: Print the current state after all physics logic executes

	# Flip sprite depending on horizontal velocity
	if walkDirection > 0:
		$AnimatedSprite2D.flip_h = false
	elif walkDirection < 0:
		$AnimatedSprite2D.flip_h = true

	# Character will slide along surfaces when moving
	move_and_slide()

func stateIdle():
	$AnimatedSprite2D.play("Idle")
	
func stateWalk():
	$AnimatedSprite2D.play("Walk") #TODO: When walking animation is done, set it here

func stateJump(delta):
	$AnimatedSprite2D.play("Jump") #TODO: When jump animation is done, set it here
	applyGravity(delta) # Gravity

func stateFall(delta):
	$AnimatedSprite2D.play("Fall") #TODO: When fall animation is done, set it here
	applyGravity(delta) # Gravity
	
func stateAbility():
	$AnimatedSprite2D.play("Idle") #TODO: When the dash animation is done, set it here

# Function to apply gravity
func applyGravity(delta):
	# Apply gravity to vertical velocity until max falling speed reached
	if not is_on_floor() and velocity.y < fallSpeedMax:
		velocity.y += gravity * delta

func _on_dash_duration_timeout():
	currentState = state.Idle