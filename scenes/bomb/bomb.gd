class_name Bomb
extends CharacterBody2D

signal exploded

const BOMB_EXPLOSION := preload("uid://ch58jhxoq461i")

# To prevent multiple explosions from one bomb during one physics frame,
# cuz bomb disappear only in next frame cuz of call_deferred.
var is_exploded := false

@onready var fuse_timer: Timer = $FuseTimer
@onready var bomb_area: Area2D = $BombArea


func _ready() -> void:
	bomb_area.body_exited.connect(_on_bomb_area_body_exited)
	fuse_timer.timeout.connect(_on_fuse_timeout)

	# Initially allow the player to move away from the bomb
	_set_bomb_collision_for_player(false)


func explode() -> void:
	if not is_exploded:
		is_exploded = true
		exploded.emit()
		_spawn_crest_explosion(2)
		queue_free()


func _spawn_crest_explosion(radius: int) -> void:
	# First explosion at the center
	_spawn_explosion_at_offset(Vector2.ZERO)

	# Explosions in four directions
	var directions: Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for direction in directions:
		for i in range(1, radius + 1):
			var offset = direction * i * Globals.TILE_SIZE

			# Check for walls, can't explode them and can't go through them.
			var query_for_explodable = PhysicsPointQueryParameters2D.new()
			query_for_explodable.collide_with_areas = false
			query_for_explodable.collide_with_bodies = true
			query_for_explodable.position = global_position + offset
			query_for_explodable.collision_mask = pow(2, Globals.CollisionLayer.WORLD - 1)

			var result_for_explodable = get_world_2d().direct_space_state.intersect_point(query_for_explodable)
			if result_for_explodable.size() > 0:
				break

			_spawn_explosion_at_offset(offset)

			# Check if explosion can go through the object.
			var query_for_not_explosion_penetrable = PhysicsPointQueryParameters2D.new()
			query_for_not_explosion_penetrable.collide_with_areas = false
			query_for_not_explosion_penetrable.collide_with_bodies = true
			query_for_not_explosion_penetrable.position = global_position + offset
			query_for_not_explosion_penetrable.collision_mask = pow(2, Globals.CollisionLayer.NOT_EXPLOSION_PENETRABLE - 1)

			var result_for_non_explosion_penetrable = get_world_2d().direct_space_state.intersect_point(query_for_not_explosion_penetrable)
			if result_for_non_explosion_penetrable.size() > 0:
				break

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
	explode()
