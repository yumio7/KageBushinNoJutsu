extends Area2D
# This projectile will track murasa and fly in a constant direction until it hits an object or runs out of time.
# It will either attach to a hit object or retract back to murasa if it doesn't hit anything in time

# Constants
const retractVelocity: float = 600	# Speed that the anchor retracts to the player

# Variables
var throwVelocity: float = 400				# Will be set when instantiated in minamitsu.gd
var trackedPlayer: CharacterBody2D = null	# Will be set when instantiated in minamitsu.gd, will track the player position when retracting

# Track projectile behaviour
enum state {Active = 0, Attached = 1, Retract = 2} # Active is when first thrown, attached is when it hits something, retracting for when it hits nothing
var currentState: int = state.Active

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	# ONLY PROCEED IF TRACKEDPLAYER IS NOT NULL SO THE GAME DOESNT EXPLODE
	if trackedPlayer != null:
		# Always face the anchor away from the trackedPlayer
		look_at(trackedPlayer.position)
		
		# Depending on current state, run different functions
		# Just realized im making a state machine for a projectile. Am I cooked?
		match currentState:
			0: stateActive(delta)
			1: stateAttached()
			2: stateRetract(delta)
		
		# Set the anchorline
		$AnchorLine.set_point_position(1, (position - trackedPlayer.position) * -position.direction_to(trackedPlayer.global_position))

# State machine functions
# Move until it hits something or runs out of time
func stateActive(delta):
	$AnimatedSprite2D.play("Active")
	position.x += throwVelocity * delta

func stateAttached():
	$AnimatedSprite2D.play("Attached")
	pass

# Move back to the player position, and if the distance between them is below a threshold it deletes itself
func stateRetract(delta):
	$AnimatedSprite2D.play("Attached")
	$AnimatedSprite2D.modulate = Color(0.5, 0.5, 0.5) # Gray out the projectile
	# Thank god godot has functions to make me not have to do vector math EYAHAHAH I love vector math
	var directionToPlayer = position.direction_to(trackedPlayer.global_position)
	var distanceToPlayer = position.distance_to(trackedPlayer.global_position)

	# Retract to player, and under a certain distance the anchor will delete
	if distanceToPlayer > 30: position += directionToPlayer * retractVelocity * delta
	else: queue_free()

