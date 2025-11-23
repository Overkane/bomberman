extends Node

const MUSIC_TRACK_DUNGEON_LEVEL = &"8 Bit Dungeon Level"

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func play_music(music_name: String) -> void:
	audio_stream_player.play()
