class_name Player
extends CharacterBody2D

const BASESPEED := 300.0
const BOMB_SCENE := preload("uid://bpo5y5pvhbibe")


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * BASESPEED
	move_and_slide()

func _input(event) -> void:
	if event.is_action_pressed(&"place_bomb"):
		var bomb: Bomb = BOMB_SCENE.instantiate()
		bomb.global_position = global_position
		get_tree().root.add_child(bomb)
