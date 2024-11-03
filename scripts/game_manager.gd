extends Node

@export var world: Node2D
@export var player_prefab: PackedScene
@export var spawn_positions: Node2D
@export var bullet: PackedScene
@export var path_follow: PathFollow2D



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
	var velocity = Vector2(randf_range(700, 1500), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
