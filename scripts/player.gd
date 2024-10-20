extends CharacterBody2D
class_name Player

signal death(attacker_index: int)

@export var hat_sprite: Sprite2D
@export var joy_device_id: int = -1
@export var deadzone: float = 0.2
@export var attack_pivot: Node2D
@export var enable_attack_hitbox: Area2D
@export var health: int = 3
@export var attack_cd: float = 2

var attack_direction: Vector2
var attack_press: bool
var on_cooldown: bool = false
var player_data: MiniGameManager.PlayerData

func construct(player_data: MiniGameManager.PlayerData):
	self.player_data = player_data
	hat_sprite.modulate = player_data.color
	if len(Input.get_connected_joypads()) >= player_data.number:
		joy_device_id = Input.get_connected_joypads()[player_data.index]

func _physics_process(delta):
	if joy_device_id < 0:
		return
	var direction = Vector2(Input.get_joy_axis(joy_device_id, JOY_AXIS_LEFT_X), Input.get_joy_axis(joy_device_id, JOY_AXIS_LEFT_Y))
	direction.normalized()
	if direction.length() < deadzone:
		direction = Vector2.ZERO
	var new_attack_direction = Vector2(Input.get_joy_axis(joy_device_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(joy_device_id, JOY_AXIS_RIGHT_Y))
	new_attack_direction.normalized()
	if new_attack_direction.length() < deadzone:
		new_attack_direction = Vector2.ZERO
	if new_attack_direction != Vector2.ZERO:
		attack_direction = new_attack_direction
	attack_pivot.rotation = attack_direction.angle() + deg_to_rad(180)
	velocity = direction * 600
	if velocity.x <= -1:
		get_node("CharacterPlaceholder_png").flip_h = false
	elif velocity.x >= 1:
		get_node("CharacterPlaceholder_png").flip_h = true
	move_and_slide()
	
	var new_attack_press = Input.is_joy_button_pressed(joy_device_id, JOY_BUTTON_RIGHT_SHOULDER)
	if new_attack_press && new_attack_press != attack_press && !on_cooldown:
		attack()
	attack_press = new_attack_press
	
func attack():
	on_cooldown = true
	enable_attack_hitbox.monitoring = true
	await get_tree().physics_frame
	enable_attack_hitbox.monitoring = false
	await get_tree().create_timer(2).timeout
	on_cooldown = false

func bullet_hit():
	queue_free()

func player_hit(attacker_index: int):
	health -= 1
	if health <= 0:
		death.emit(attacker_index)
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	var other_player: Player = body
	other_player.player_hit(player_data.index)
