extends CharacterBody2D
class_name Player

signal death(attacker_index: int)

@export var hat_sprite: AnimatedSprite2D
@export var joy_device_id: int = -1
@export var deadzone: float = 0.2
@export var attack_pivot: Node2D
@export var enable_attack_hitbox: Area2D
@export var health: int = 3
@export var attack_cd: float = 2
@export var bull: Bullet
@onready var bullet = get_node("/root/Game/bullet_obj")

var attack_direction: Vector2
var attack_press: bool
var on_cooldown: bool = false
var player_data: MiniGameManager.PlayerData
var speed = 400
var hurt: bool = false

func construct(player_data: MiniGameManager.PlayerData):
	self.player_data = player_data
	hat_sprite.modulate = player_data.color
	_on_joy_connection_changed()
	Input.joy_connection_changed.connect(_on_joy_connection_changed.unbind(2))

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
	velocity = direction * speed
	if velocity.x != 0 || velocity.y != 0:
		get_node("HatSprite").play("default")
		if !hurt:
			get_node("CharacterSprite").play("walk")
		else:
			get_node("CharacterSprite").play("hurtwalk")
	else:
		if !on_cooldown:
			get_node("HatSprite").play("idle")
			if !hurt:
				get_node("CharacterSprite").play("idle")
			else:
				get_node("HatSprite").play("default")
				get_node("CharacterSprite").play("hurt")
	if attack_direction.x <= -0.1:
		get_node("CharacterSprite").flip_h = false
		get_node("HatSprite").flip_h = false
	elif attack_direction.x >= 0.1:
		get_node("CharacterSprite").flip_h = true
		get_node("HatSprite").flip_h = true
	move_and_slide()
	
	var new_attack_press = Input.is_joy_button_pressed(joy_device_id, JOY_BUTTON_RIGHT_SHOULDER)
	if new_attack_press && new_attack_press != attack_press && !on_cooldown:
		attack()
	attack_press = new_attack_press
	
func attack():
	on_cooldown = true
	get_node("CharacterSprite").play("smash")
	get_node("AttackPivot/Area2D/SmashSprite").play("smash")
	get_node("HatSprite").play("smash")
	speed = 0
	enable_attack_hitbox.monitoring = true
	await get_tree().physics_frame
	enable_attack_hitbox.monitoring = false
	await get_tree().create_timer(1).timeout
	speed = 400
	await get_tree().create_timer(1).timeout
	get_node("AttackPivot/Area2D/SmashSprite").play("default")
	get_node("CharacterSprite").play("idle")
	get_node("HatSprite").play("idle")
	on_cooldown = false
	
	#func attack():
	#on_cooldown = true
	#get_node("CharacterSprite").play("smash")
	#get_node("AttackPivot/Area2D/SmashSprite").play("smash")
	#get_node("HatSprite").play("smash")
	#speed = 0
	#await get_tree().create_timer(0.5).timeout
	#enable_attack_hitbox.monitoring = true
	#await get_tree().physics_frame
	#enable_attack_hitbox.monitoring = false
	#await get_tree().create_timer(1).timeout
	#speed = 400
	#await get_tree().create_timer(1).timeout
	#get_node("AttackPivot/Area2D/SmashSprite").play("default")
	#get_node("CharacterSprite").play("idle")
	#get_node("HatSprite").play("idle")
	#on_cooldown = false

func bullet_hit(attacker_index:int):
	health -= 1
	hurt = true
	if health <= 0:
		death.emit(attacker_index)
		queue_free()
	await get_tree().create_timer(1).timeout
	hurt = false

func player_hit(attacker_index: int):
	health -= 1
	get_node("CharacterSprite").play("hurt")
	get_node("HatSprite").play("default")
	speed = 0
	on_cooldown = true
	if health <= 0:
		death.emit(attacker_index)
		queue_free()
	await get_tree().create_timer(1).timeout
	on_cooldown = false
	speed = 400
	get_node("CharacterSprite").play("idle")
	get_node("HatSprite").play("idle")
	
	#func player_hit(attacker_index: int):
	#health -= 1
	#get_node("CharacterSprite").play("hurt")
	#get_node("HatSprite").play("default")
	#speed = 0
	#on_cooldown = true
	#if health <= 0:
	#	death.emit(attacker_index)
	#	queue_free()
	#await get_tree().create_timer(1).timeout
	#on_cooldown = false
	#speed = 400
	#get_node("CharacterSprite").play("idle")
	#get_node("HatSprite").play("idle")


func _on_area_2d_body_entered(body: Node2D) -> void:
	var other_player: Player = body
	if body != self:
		other_player.player_hit(player_data.index)
func _on_joy_connection_changed():
	if len(Input.get_connected_joypads()) >= player_data.number:
		joy_device_id = Input.get_connected_joypads()[player_data.index]


func _on_bull_hurtbox_body_entered(body: Node2D) -> void:
	if body != self:
		self.bullet_hit(player_data.index)
