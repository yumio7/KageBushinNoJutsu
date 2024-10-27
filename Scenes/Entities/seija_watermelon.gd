extends Area2D

# Le melon

var bulletVelocity: Vector2 = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation_degrees += 5
	position += bulletVelocity * delta

func _on_death_timer_timeout() -> void:
	var deathTween = create_tween()
	deathTween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), .1)
	deathTween.tween_callback(queue_free)

func _on_body_entered(body:Node2D) -> void:
	if body is CharacterBody2D:
		body.bulletHit()
