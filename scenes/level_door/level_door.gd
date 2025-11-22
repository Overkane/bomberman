class_name LevelDoor
extends Area2D

signal level_door_entered

var _is_open := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func open_door():
	_is_open = true


func _on_body_entered(_body: Node) -> void:
	if _is_open:
		level_door_entered.emit()
