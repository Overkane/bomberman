## Enemy, which goes forward until it hits a wall/bomb/box,
## then turns, preffering turning right and opposite _direction being the least priority.
class_name Fool
extends Enemy

# Since enemy collision shape a bit smaller, than distance between tiles, add additional
# margin, so enemy doesn't rotate into the wall right next to it to move for a bit.
const _COLLISION_MARGIN := 1


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	velocity = _direction * _speed
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision_info:
		velocity = _direction.rotated(PI / 2) * _speed
		collision_info = move_and_collide(velocity * delta, true, _COLLISION_MARGIN)
		if not collision_info:
			_direction = _direction.rotated(PI / 2)
			_update_animation()
		else:
			velocity = _direction.rotated(-PI / 2) * _speed
			collision_info = move_and_collide(velocity * delta, true, _COLLISION_MARGIN)
			if not collision_info:
				_direction = _direction.rotated(-PI / 2)
				_update_animation()
			else:
				_direction = _direction.rotated(PI)
				_update_animation()
