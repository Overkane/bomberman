## Simple enemy, which goes forward until it hits a wall/bomb/box,
## then turns, preffering turning right and opposite direction being the least priority.
class_name Fool
extends CharacterBody2D

signal exploded

const BASE_SPEED := 100.0
# Since enemy collision shape a bit smaller, than distance between tiles, add additional
# margin, so enemy doesn't rotate into the wall right next to it to move for a bit.
const COLLISION_MARGIN := 1.0

var direction := Vector2.RIGHT


func _physics_process(delta: float) -> void:
	velocity = direction * BASE_SPEED
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = direction.rotated(PI / 2) * BASE_SPEED
		collision_info = move_and_collide(velocity * delta, true, COLLISION_MARGIN)
		if not collision_info:
			direction = direction.rotated(PI / 2)
		else:
			velocity = direction.rotated(-PI / 2 * BASE_SPEED)
			collision_info = move_and_collide(velocity * delta, true, COLLISION_MARGIN)
			if not collision_info:
				direction = direction.rotated(-PI / 2)
			else:
				direction = direction.rotated(PI)


func explode() -> void:
	exploded.emit()
	queue_free()
