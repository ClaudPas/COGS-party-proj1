extends RigidBody2D
class_name Bullet

@export var min_speed = 150.0
@export var max_speed = 250.0

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
