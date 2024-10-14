extends CharacterBody2D
# TODO (If possible)
# Coyote time
# Jump buffer
# Variant jump height depending on how long the jump input is held

# Constants. Assigned values cannot be changed
const walkSpeed: float = 50.0			# Base walking Movement speed
const walkSpeedMax: float = 200.0		# Maximum walking movement speed. Kagerou cannot move faster than this when walking.
const jumpVelocity: float = -200.0		# Jump velocity. It is negative because in Godot up is negative y.
const fallSpeedMax: float = 250.0		# Maximum fall velocity. Kagerou cannot fall faster than this.
const dashVelocity: float = 300.0		# Dash velocity.
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Tracks state of character for different movement behaviours
enum state {Idle = 0, Walk = 1, Jump = 2, Fall = 3, Ability = 4}	# Define enum for every state
var currentState: int = state.Idle									# Tracks the current state. By default, it is set to idle.
var walkDirection = 0												# Keep track of whether controls for walking are being held down

# Runs once when the character is instantiated
func _ready() -> void:
	pass

# Runs every physics frame (60fps)
func _physics_process(delta: float) -> void:
	
	print("0-" + str(currentState)) # FOR DEBUGGING: Print the current state before all physics logic executes

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
		# Check if player is inputting jump. Depending on how long they input, their jump height will change
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			$Timers/JumpHeightTimer.start()
			velocity.y = jumpVelocity
		elif Input.is_action_pressed("Jump") and !is_on_floor() and $Timers/JumpHeightTimer.time_left > 0:
			velocity.y = jumpVelocity
		elif Input.is_action_just_released("Jump"):
			$Timers/JumpHeightTimer.stop() # Edge case in case the player inputs fast enough to jump again

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

	print("1-" + str(currentState)) # FOR DEBUGGING: Print the current state after all physics logic executes

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
	$AnimatedSprite2D.play("Idle") #TODO: When walking animation is done, set it here

func stateJump(delta):
	$AnimatedSprite2D.play("Idle") #TODO: When jump animation is done, set it here
	applyGravity(delta) # Gravity

func stateFall(delta):
	$AnimatedSprite2D.play("Idle") #TODO: When fall animation is done, set it here
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