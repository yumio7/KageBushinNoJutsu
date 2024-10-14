extends AnimatedSprite2D

# Variables
var movementSpeed = 30
var hasPizza = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += movementSpeed * delta

# Called every physics frame. A fixed time scale of 60FPS
func _physics_process(delta: float) -> void:
	pass