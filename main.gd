extends Node2D

const _PERMANENT_BONUS_CHOOSER = preload("uid://bna7qyy6d8r7g")
const _PLAYER_SCENE = preload("uid://ckogy8ldbtbum")
const _LEVEL1_SCENE = preload("uid://bst1tonp0snoa")
const _LEVEL2_SCENE = preload("uid://dw24fwv23rp6x")

const _LEVEL_LIST: Array[PackedScene] = [
	_LEVEL1_SCENE,
	_LEVEL2_SCENE,
]

var _current_level_list: Array[PackedScene]
var _player: Player

@onready var _start_button: Button = %StartButton
@onready var _ui: CanvasLayer = %UI
@onready var _screen_fade: ColorRect = %ScreenFade


func _ready() -> void:
	_start_button.grab_focus.call_deferred()
	_start_button.pressed.connect(_start_game)
	MusicManager.play_music(MusicManager.MUSIC_TRACK_DUNGEON_LEVEL)


func _start_game() -> void:
	_start_button.hide()
	_current_level_list = _LEVEL_LIST.duplicate()
	_player = _PLAYER_SCENE.instantiate()
	_load_next_level()

func _load_next_level() -> void:
	var next_level_scene: PackedScene = _current_level_list.pop_front()
	var next_level: Level = next_level_scene.instantiate()
	_player.global_position = next_level.get_player_spawn_point()
	add_child(next_level)

	next_level.add_child(_player)

	next_level.level_finished.connect(_on_level_finished.bind(next_level))

func _toggle_screen_fade() -> Tween:
	var tween := create_tween()
	tween.tween_property(_screen_fade, "modulate:a", 1.0 - _screen_fade.modulate.a, 1.33)
	return tween


func _on_level_finished(finished_level: Level) -> void:
	if _current_level_list.size() == 0:
		print("Game Finished!")
		return

	# Fade out to clear stuff and create permanent bonus chooser.
	await _toggle_screen_fade().finished
	finished_level.remove_child(_player)
	finished_level.queue_free()
	BonusHandler.clear_temporary_bonuses()
	_player.process_mode = Node.PROCESS_MODE_DISABLED

	var permanent_bonus_chooser: PermanentBonusChooser = _PERMANENT_BONUS_CHOOSER.instantiate()
	permanent_bonus_chooser.bonus_selected.connect(func(bonus_type: BonusHandler.BonusType) -> void:
		BonusHandler.apply_bonus(_player, bonus_type, true)
	)
	_ui.add_child(permanent_bonus_chooser)

	# Fade in to show permanent bonus chooser.
	await _toggle_screen_fade().finished

	await permanent_bonus_chooser.bonus_selected

	# Fade out to remove permanent bonus chooser and load next level.
	await _toggle_screen_fade().finished
	permanent_bonus_chooser.queue_free()

	_load_next_level()

	# Fade in to show next level.
	await _toggle_screen_fade().finished
	_player.process_mode = Node.PROCESS_MODE_INHERIT
