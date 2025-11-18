class_name DestructibleBox
extends CharacterBody2D

func explode() -> void:
	queue_free()
