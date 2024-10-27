extends Area2D

var bulletVelocity: Vector2 = Vector2.ZERO
var bounceCount = 1	# Amount of bounces that can occured

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	look_at(position - bulletVelocity)
	position += bulletVelocity * delta


# When hitting a body, it will bounce once before being destroyed
func _on_body_entered(body:Node2D) -> void:
	if body is CharacterBody2D:
		body.bulletHit()
		queue_free()
	elif bounceCount > 0:
		bounceCount -= 1
		var hitNormal = $RayCast2D.get_collision_normal()
		if hitNormal != Vector2(0, 0):
			bulletVelocity = bulletVelocity.bounce(hitNormal)
			$AnimatedSprite2D.play("Bounce")
	else:
		queue_free()

func _on_death_timer_timeout() -> void:
	queue_free()	
