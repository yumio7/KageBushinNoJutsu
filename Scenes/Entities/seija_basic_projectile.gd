extends Area2D
# A basic attack projectile from seija

var bulletVelocity: Vector2 = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += bulletVelocity * delta

func _on_body_entered(body:Node2D) -> void:
	if body is CharacterBody2D:
		body.bulletHit()
	queue_free()


func _on_death_timer_timeout() -> void:
	queue_free()
