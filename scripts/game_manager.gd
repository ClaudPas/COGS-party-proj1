extends Node

@export var world: Node2D
@export var player_prefab: PackedScene
@export var spawn_positions: Node2D
<<<<<<< Updated upstream
@export var bullet: PackedScene
@export var path_follow: PathFollow2D

=======
@export var timer: Label
@export var minigame_manager: MiniGameManager
@export var time: float = 180
@export var bullet: PackedScene
@export var path_follow: PathFollow2D
>>>>>>> Stashed changes


func _ready():
	MiniGameManager.game_started.connect(on_game_started)
	
func on_game_started(player_data_array: Array):
	print(JSON.stringify(player_data_array))
	for i in range(len(player_data_array)):
		var player_data: MiniGameManager.PlayerData = player_data_array[i]
		var player_instance: Player = player_prefab.instantiate()
		world.add_child(player_instance)
		player_instance.construct(player_data)
		player_instance.position = spawn_positions.get_child(i).position
		
	


func _on_mob_timer_timeout():
	var bullet = load("res://scenes/bullet.tscn")
# Create a new instance of the Mob scene.
	var mob = bullet.instantiate()

<<<<<<< Updated upstream
=======
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
	var bullet = load("res://scenes/bullet_obj.tscn")
# Create a new instance of the Mob scene.
	var mob = bullet.instantiate()

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
	var velocity = Vector2(randf_range(700, 1500), 0.0)
=======
	var velocity = Vector2(randf_range(150, 750), 0.0)
>>>>>>> Stashed changes
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
