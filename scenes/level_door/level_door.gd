class_name LevelDoor
extends Area2D

signal level_door_entered

const OPEN_DOOR_SPRITE := preload("uid://bpc5b6ow8bgrp")

var _is_open := false

@onready var sprite_2d: Sprite2D = %Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func open_door():
	_is_open = true
	sprite_2d.texture = OPEN_DOOR_SPRITE



func _on_body_entered(_body: Node) -> void:
	if _is_open:
		SoundManager.play_sound(SoundManager.SOUND_TYPE.ENTER_DOOR)
		level_door_entered.emit()
