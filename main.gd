extends Node2D

const PLAYER_SCENE = preload("uid://ckogy8ldbtbum")
const LEVEL1_SCENE = preload("uid://bst1tonp0snoa")
const LEVEL2_SCENE = preload("uid://dw24fwv23rp6x")

const level_list: Array[PackedScene] = [
	LEVEL1_SCENE,
	LEVEL2_SCENE,
]

var current_level_list: Array[PackedScene]
var player: Player

@onready var start_button: Button = %StartButton
@onready var ui: CanvasLayer = %UI


func _ready() -> void:
	start_button.grab_focus.call_deferred()
	start_button.pressed.connect(_start_game)


func _start_game() -> void:
	current_level_list = level_list.duplicate()
	player = PLAYER_SCENE.instantiate()
	_load_next_level()

func _load_next_level() -> void:
	if current_level_list.size() == 0:
		ui.visible = true
		print("Game Finished!")
	else:
		ui.visible = false # TODO Only first time
		var next_level_scene: PackedScene = current_level_list.pop_front()
		var next_level: Level = next_level_scene.instantiate()
		add_child(next_level)

		player.global_position = next_level.get_player_spawn_point()
		# Since finished level won't be freed instantly, add player 1 frame later, so it won't
		# enter the level door of the finished level again and such to prevent infinite loop of
		# entering the door and finishing the level of finished level.
		add_child.call_deferred(player)

		next_level.level_finished.connect(func():
			BonusHandler.clear_temporary_bonuses()
			next_level.queue_free()
			remove_child(player)
			_load_next_level()
		)
