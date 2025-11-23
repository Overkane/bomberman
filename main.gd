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
var _current_level: Level
var _player: Player

@onready var _start_button: Button = %StartButton
@onready var _ui: CanvasLayer = %UI
@onready var _screen_fade: ColorRect = %ScreenFade
@onready var _game_finish_screen: PanelContainer = %GameFinishScreen
@onready var _sound_slider: HSlider = %SoundSlider
@onready var _main_menu: Control = %MainMenu


func _ready() -> void:
	_start_button.grab_focus.call_deferred()
	_start_button.pressed.connect(_start_game)
	MusicManager.play_music(MusicManager.MUSIC_TRACK_DUNGEON_LEVEL)
	AudioServer.set_bus_volume_db(0, linear_to_db(0.5))
	_sound_slider.set_value_no_signal(0.5)
	_sound_slider.value_changed.connect(func(value: float):
		AudioServer.set_bus_volume_db(0, linear_to_db(value))
	)


func _start_game() -> void:
	await _toggle_screen_fade().finished
	_main_menu.hide()
	_current_level_list = _LEVEL_LIST.duplicate()
	_player = _PLAYER_SCENE.instantiate()
	_player.exploded.connect(_on_player_exploded)
	_load_next_level()
	await _toggle_screen_fade().finished

func _load_next_level() -> void:
	var next_level_scene: PackedScene = _current_level_list.pop_front()
	_current_level = next_level_scene.instantiate()
	_player.global_position = _current_level.get_player_spawn_point()
	add_child(_current_level)

	_current_level.add_child(_player)
	_current_level.level_finished.connect(_on_level_finished)

func _toggle_screen_fade() -> Tween:
	var tween := create_tween()
	tween.tween_property(_screen_fade, "modulate:a", 1.0 - _screen_fade.modulate.a, 0.75)
	return tween


func _on_level_finished() -> void:
	if _current_level_list.size() == 0:
		_game_finish_screen.show()
		_player.process_mode = Node.PROCESS_MODE_DISABLED
		return

	# Fade out to clear stuff and create permanent bonus chooser.
	await _toggle_screen_fade().finished
	_current_level.remove_child(_player)
	_current_level.queue_free()
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

func _on_player_exploded() -> void:
	# Fade out to clear stuff
	await _toggle_screen_fade().finished

	_current_level.queue_free()
	_main_menu.show()
	# Fade in to show menu again.
	await _toggle_screen_fade().finished
