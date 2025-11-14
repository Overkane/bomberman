class_name Player
extends CharacterBody2D

const BASESPEED = 300.0


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * BASESPEED
	move_and_slide()
