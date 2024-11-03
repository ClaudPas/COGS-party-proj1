extends CharacterBody2D
class_name Player

@export var hat_sprite: Sprite2D
@export var joy_device_id: int = -1
@export var deadzone: float = 0.2

func construct(player_data: MiniGameManager.PlayerData):
	hat_sprite.modulate = player_data.color
	if len(Input.get_connected_joypads()) >= player_data.number:
		joy_device_id = Input.get_connected_joypads()[player_data.index]

func _physics_process(_delta):
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if joy_device_id < 0:
		return
	var direction = Vector2(Input.get_joy_axis(joy_device_id, JOY_AXIS_LEFT_X), Input.get_joy_axis(joy_device_id, JOY_AXIS_LEFT_Y))
	direction.normalized()
	if direction.length() < deadzone:
		direction = Vector2.ZERO
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
	
func bullet_hit(_body):
	emit_signal("hit")
	queue_free()
