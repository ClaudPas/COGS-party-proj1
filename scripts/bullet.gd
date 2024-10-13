extends Area2D

var distance_travelled = 0;

func _physics_process(delta):
	const SPEED = 1000
	const RANGE = 1200
	
	var direction = Vector2.LEFT.rotated(rotation)
	position += direction * 1000.0 * delta
	
	distance_travelled += SPEED * delta
	if(distance_travelled > RANGE):
		queue_free()


func _on_body_entered(body):
	if body.has_method("bullet_hit"):
		body.bullet_hit()
		
