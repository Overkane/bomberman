class_name DestructibleBox
extends CharacterBody2D

signal exploded


func explode() -> void:
	exploded.emit()
	queue_free()
