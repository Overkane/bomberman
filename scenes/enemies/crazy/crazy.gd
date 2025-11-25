## Randomly changes direction over time or when hits solid object.
class_name Crazy
extends CharacterBody2D

signal exploded

const _BASE_SPEED := 95.0
# Since enemy collision shape a bit smaller, than distance between tiles, add additional
# margin, so enemy doesn't rotate into the wall right next to it to move for a bit.
const _COLLISION_MARGIN := 1.0

var _direction := Vector2.RIGHT
var _is_dead := false

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var crazy_timer: Timer = $CrazyTimer


func _ready() -> void:
	crazy_timer.start(randi_range(2, 5))
	crazy_timer.timeout.connect(func():
		var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
		directions.erase(_direction)
		_direction = directions[randi() % directions.size()]
		_update_animation()
		crazy_timer.start(randi_range(2, 5))
	)
	_update_animation()

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
			_update_animation()
		else:
			velocity = _direction.rotated(-PI / 2) * _BASE_SPEED
			collision_info = move_and_collide(velocity * delta, true, _COLLISION_MARGIN)
			if not collision_info:
				_direction = _direction.rotated(-PI / 2)
				_update_animation()
			else:
				_direction = _direction.rotated(PI)
				_update_animation()


func explode() -> void:
	if _is_dead:
		return
	SoundManager.play_sound(SoundManager.SoundType.HIT)
	_is_dead = true
	exploded.emit()
	var tween = create_tween()
	tween.tween_method(_set_percent, 1.0, 0.0, 0.85)
	await tween.finished
	queue_free()


func _update_animation() -> void:
	if _direction.is_equal_approx(Vector2.RIGHT):
		_animated_sprite_2d.animation = "move_right"
	elif _direction.is_equal_approx(Vector2.LEFT):
		_animated_sprite_2d.animation = "move_left"
	elif _direction.is_equal_approx(Vector2.UP):
		_animated_sprite_2d.animation = "move_up"
	elif _direction.is_equal_approx(Vector2.DOWN):
		_animated_sprite_2d.animation = "move_down"
	_animated_sprite_2d.play()

func _set_percent(percentage: float) -> void:
	material.set_shader_parameter('percentage', percentage)
