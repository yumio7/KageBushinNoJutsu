extends CanvasLayer

var timer = 0;
var thunderDuration = 45 # duration of lightning/thunder FX in frames
var thunderInterval = 75; # max duration of time between thunder FX in frames

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (timer == 0):
		var viewport = get_viewport();
		var center = viewport.get_camera_2d().get_screen_center_position()
		var randx = randf()*(viewport.get_visible_rect().size.x/2)
		var randy = randf()*(viewport.get_visible_rect().size.y/2)
		$BackgroundThunder1.set_position(Vector2(center.x + randx, -randy))
		$BackgroundThunder2.set_position(Vector2(center.x - randx, -randy));
		$AudioStreamPlayer2D.play()
	if (timer > 0 and timer < thunderDuration):
		$BrightenCanvasLayer/ColorRect.material.set_shader_parameter("colourAdd", ((thunderDuration - timer % thunderInterval) as float / thunderDuration) * 0.05)
		$BrightenCanvasLayer/ColorRect.material.set_shader_parameter("multiplier", 1.0 + ((thunderDuration - timer % thunderInterval) as float / thunderDuration) * 0.05)
		$BackgroundThunder1/ColorRect.material.set_shader_parameter("alpha", 1.0 - ((timer % thunderInterval) as float / thunderDuration))
		$BackgroundThunder2/ColorRect.material.set_shader_parameter("alpha", 1.0 - ((timer % thunderInterval) as float / thunderDuration))
	if (timer == thunderInterval):
		timer = randi_range(0, -thunderInterval);
	timer += 1;

