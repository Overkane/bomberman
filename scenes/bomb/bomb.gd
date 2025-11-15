class_name Bomb
extends CharacterBody2D

const BOMB_EXPLOSION := preload("uid://ch58jhxoq461i")

@onready var fuse_timer: Timer = $FuseTimer
@onready var bomb_area: Area2D = $BombArea


func _ready() -> void:
	bomb_area.body_exited.connect(_on_bomb_area_body_exited)
	fuse_timer.timeout.connect(_on_fuse_timeout)

	# Initially allow the player to move away from the bomb
	_set_bomb_collision_for_player(false)


func _spawn_crest_explosion(radius: int) -> void:
	# First explosion at the center
	_spawn_explosion_at_offset(Vector2.ZERO)

	# Explosions in four directions
	var directions: Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for direction in directions:
		for i in range(1, radius + 1):
			_spawn_explosion_at_offset(direction * i * Globals.TILE_SIZE)

func _spawn_explosion_at_offset(offset: Vector2) -> void:
	var explosion: BombExplosion = BOMB_EXPLOSION.instantiate()
	explosion.global_position = global_position + offset
	get_tree().root.add_child(explosion)

func _set_bomb_collision_for_player(enabled: bool) -> void:
	set_collision_layer_value(Globals.CollisionLayer.BOMB_FOR_PLAYER, enabled)
	set_collision_mask_value(Globals.CollisionLayer.PLAYER, enabled)


func _on_bomb_area_body_exited(body: Node) -> void:
	if body is Player:
		# Once the player has moved away, enable collision with the bomb
		_set_bomb_collision_for_player(true)

func _on_fuse_timeout() -> void:
	_spawn_crest_explosion(2)
	queue_free()
