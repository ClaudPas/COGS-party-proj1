extends Node

@export var world: Node2D
@export var player_prefab: PackedScene
@export var spawn_positions: Node2D

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
