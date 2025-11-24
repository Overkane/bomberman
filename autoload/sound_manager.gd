extends Node

enum SoundType {
	HIT = 0,
	BOOM = 1,
	ENTER_DOOR = 2,
	PLACE_BOMB = 3,
	POWERUP = 4,
}

@export var _sound_list: Dictionary[SoundType, AudioStream]

@onready var _audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer


func _ready() -> void:
	_audio_stream_player.play()


func play_sound(sound_type: SoundType):
	if not _audio_stream_player.playing:
		_audio_stream_player.play()

	var playback = _audio_stream_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
	playback.play_stream(_sound_list.get(sound_type))
