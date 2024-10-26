extends AnimatedSprite2D
const lifespan: float = 10;
var timer: float = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer+=1;
	play("default");
	if (timer > lifespan):
		queue_free()
	
