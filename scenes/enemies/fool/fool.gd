## Simple enemy, which goes forward until it hits a wall/bomb/box,
## then turns, preffering turning right and opposite _direction being the least priority.
class_name Fool
extends CharacterBody2D

signal exploded

const _BASE_SPEED := 100.0
# Since enemy collision shape a bit smaller, than distance between tiles, add additional
# margin, so enemy doesn't rotate into the wall right next to it to move for a bit.
const _COLLISION_MARGIN := 1.0

var _direction := Vector2.RIGHT
var _is_dead := false


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	velocity = _direction * _BASE_SPEED
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision_info:
		velocity = _direction.rotated(PI / 2) * _BASE_SPEED
		collision_info = move_and_collide(velocity * delta, true, _COLLISION_MARGIN)
		if not collision_info:
			_direction = _direction.rotated(PI / 2)
		else:
			velocity = _direction.rotated(-PI / 2 * _BASE_SPEED)
			collision_info = move_and_collide(velocity * delta, true, _COLLISION_MARGIN)
			if not collision_info:
				_direction = _direction.rotated(-PI / 2)
			else:
				_direction = _direction.rotated(PI)


func explode() -> void:
	if _is_dead:
		return

	_is_dead = true
	exploded.emit()
	var tween = create_tween()
	tween.tween_method(_set_percent, 1.0, 0.0, 0.85)
	await tween.finished
	queue_free()


func _set_percent(percentage: float) -> void:
	material.set_shader_parameter('percentage', percentage)
