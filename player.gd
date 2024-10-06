extends CharacterBody2D

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	if velocity.x <= -1:
		get_node("CharacterPlaceholder_png").flip_h = false
	elif velocity.x >= 1:
		get_node("CharacterPlaceholder_png").flip_h = true
	move_and_slide()
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		get_node("CharacterPlaceholder_png").flip_v = true
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			get_node("CharacterPlaceholder_png").flip_v = false
	
func bullet_hit():
	queue_free()
