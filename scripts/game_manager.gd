extends Node
class_name GameManager

static var global: GameManager

@export var world: Node2D
@export var player_prefab: PackedScene
@export var spawn_positions: Node2D
@export var timer: Label
@export var minigame_manager: MiniGameManager
@export var time: float = 180
@export var bullet: PackedScene
@export var path_follow: PathFollow2D

var player_kills_dict = {}
var player_deaths_dict = {}
var player_data_arr = []


func _ready():
	minigame_manager.game_started.connect(on_game_started)
	if global != null:
		queue_free()
		return
	global = self

func on_game_started(player_data_array: Array):
	player_data_arr = player_data_array
	print(JSON.stringify(player_data_array))
	for i in range(len(player_data_array)):
		spawn_player(i)

func on_player_death(attacker_index: int, victim_index: int):
	if attacker_index == victim_index:
		player_kills_dict[attacker_index] -= 1
	player_kills_dict[attacker_index] += 1
	player_deaths_dict[victim_index] += 1
	await get_tree().create_timer(3).timeout
	spawn_player(victim_index)

func _process(delta: float) -> void:
	time -= delta
	timer.text = str(ceil(time))
	if time <= 0:
		var points = []
		for player_index in player_kills_dict:
			points.append({
				"points": player_kills_dict[player_index] - player_deaths_dict[player_index],
				"player": player_index
			})
		points.sort_custom(func(a, b): b.points - a.points)
		var rewards = [3, 2, 1]
		var results = []
		for i in range(len(points)):
			if i >= len(rewards):
				break
			results.append({
				"points": rewards[i],
				"player": points[i].player
			})
		minigame_manager.end_game(results)

func spawn_player(player_index: int):
	var player_data = player_data_arr[player_index]
	var player_instance: Player = player_prefab.instantiate()
	world.add_child(player_instance)
	player_instance.construct(player_data)
	player_instance.position = spawn_positions.get_child(player_index).position
	player_kills_dict[player_index] = 0
	player_deaths_dict[player_index] = 0
	player_instance.death.connect(on_player_death.bind(player_index))


func _on_mob_timer_timeout():
	bullet = load("res://scenes/bullet_obj.tscn")
# Create a new instance of the Mob scene.
	var mob = bullet.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.

	var velocity = Vector2(randf_range(250, 250), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	#mob.set_deferred("collision_layer", 0)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
