## Like Fool, but randomly changes direction over time or when hits solid object.
class_name Crazy
extends Enemy

# Since enemy collision shape a bit smaller, than distance between tiles, add additional
# margin, so enemy doesn't rotate into the wall right next to it to move for a bit.
const _COLLISION_MARGIN := 1.0

@onready var crazy_timer: Timer = $CrazyTimer


func _ready() -> void:
	super ()
	crazy_timer.start(randi_range(2, 5))
	crazy_timer.timeout.connect(func():
		var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
		directions.erase(_direction)
		_direction = directions[randi() % directions.size()]
		_update_animation()
		crazy_timer.start(randi_range(2, 5))
	)

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
