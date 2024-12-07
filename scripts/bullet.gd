extends RigidBody2D
class_name Bullet

@export var min_speed = 150.0
@export var max_speed = 250.0
@export var bullet_hit: RigidBody2D
@export var player: Player



func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body: Node) -> void:
	bullet_hit.contact_monitor = true
	if body.has_method("bullet_hit"):
		body.bullet_hit()
	bullet_hit.contact_monitor = false
