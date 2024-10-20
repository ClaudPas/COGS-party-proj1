extends Node
class_name GameManager

static var global: GameManager

@export var world: Node2D
@export var player_prefab: PackedScene
@export var spawn_positions: Node2D
@export var timer: Label
@export var minigame_manager: MiniGameManager
@export var time: float = 180

var player_kills_dict = {}
var player_deaths_dict = {}

func _ready():
	minigame_manager.game_started.connect(on_game_started)
	if global != null:
		queue_free()
		return
	global = self

func on_game_started(player_data_array: Array):
	print(JSON.stringify(player_data_array))
	for i in range(len(player_data_array)):
		var player_data: MiniGameManager.PlayerData = player_data_array[i]
		var player_instance: Player = player_prefab.instantiate()
		world.add_child(player_instance)
		player_instance.construct(player_data)
		player_instance.position = spawn_positions.get_child(i).position
		player_kills_dict[i] = 0
		player_deaths_dict[i] = 0
		player_instance.death.connect(on_player_death.bind(i))

func on_player_death(attacker_index: int, victim: int):
	player_kills_dict[attacker_index] += 1
	player_deaths_dict[victim] += 1

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
			results.append[{
				"points": rewards[i],
				"player": points[i].player
			}]
		minigame_manager.end_game(results)
