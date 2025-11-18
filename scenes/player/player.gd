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
		# Bomb shoulbe be placed only in the center of each tile, which will be the half of tile size.
		# To exclude position between tiles, need to check if one of coords can be divided by tile size.
		# If it is, then need to add offset to the closest tile center.
		var snapped_position: Vector2 = snapped(global_position, Vector2(Globals.TILE_SIZE, Globals.TILE_SIZE) / 2)
		if is_zero_approx(fmod(snapped_position.x, Globals.TILE_SIZE)):
			var offset_mult = 1 if global_position.x > snapped_position.x else -1
			snapped_position.x += offset_mult * Globals.TILE_SIZE / 2.0
		if is_zero_approx(fmod(snapped_position.y, Globals.TILE_SIZE)):
			var offset_mult = 1 if global_position.y > snapped_position.y else -1
			snapped_position.y += offset_mult * Globals.TILE_SIZE / 2.0
		bomb.global_position = snapped_position
		get_tree().root.add_child(bomb)


func explode() -> void:
	queue_free()
