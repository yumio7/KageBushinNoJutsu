extends CharacterBody2D
# Boss enemy.
# Tracks the player and fires danmaku patterns.


const flightSpeed: float = 100				# Speed seija will fly normally
const flightSpeedFlee: float = 500			# Speed seija will fly after being hit and fleeing to the next area
const projectileSpeed: float = 50 			# Projectile speed
const projectileMelonSpeed: float = 100		# Watermelon speed

var health: int = 6	# How many hits taken before exploding

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
