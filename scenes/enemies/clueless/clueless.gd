## Enemy, which goes forward until it hits a wall/bomb/box,
## but also has a chance to change direction before that.
## After hitting another object, turns, preffering turning right
## and opposite _direction being the least priority.
class_name Clueless
extends CharacterBody2D

signal exploded

const _BASE_SPEED := 70.0

var _direction := Vector2.RIGHT
var _is_dead := false
var _raycast_direction_map: Dictionary[Vector2, ShapeCast2D] = {}
var _can_turn := true
# TODO Use Vector2i instead of Vector2, then don't need to use aprrox equal?
var _relative_vectors: Dictionary[Vector2, Array] = {
	Vector2.UP: [Vector2.RIGHT, Vector2.LEFT],
	Vector2.DOWN: [Vector2.LEFT, Vector2.RIGHT],
	Vector2.LEFT: [Vector2.UP, Vector2.DOWN],
	Vector2.RIGHT: [Vector2.DOWN, Vector2.UP],
}

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shape_cast_down: ShapeCast2D = $ShapeCastDown
@onready var _shape_cast_left: ShapeCast2D = $ShapeCastLeft
@onready var _shape_cast_right: ShapeCast2D = $ShapeCastRight
@onready var _shape_cast_up: ShapeCast2D = $ShapeCastUp
@onready var _turn_timer: Timer = $TurnTimer


func _ready() -> void:
	_turn_timer.timeout.connect(func():
		_can_turn = true
	)

	_raycast_direction_map = {
		Vector2.DOWN: _shape_cast_down,
		Vector2.LEFT: _shape_cast_left,
		Vector2.RIGHT: _shape_cast_right,
		Vector2.UP: _shape_cast_up,
	}
	_update_animation()

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	velocity = _direction * _BASE_SPEED
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta, false)
	if collision_info:
		var relative_right_vector = _relative_vectors[_direction][0]
		var right_relative_shapecast: ShapeCast2D = _raycast_direction_map[relative_right_vector]
		right_relative_shapecast.force_shapecast_update()
		if not right_relative_shapecast.is_colliding():
			_direction = relative_right_vector
			_update_animation()
		else:
			var relative_left_vector = _relative_vectors[_direction][1]
			var left_relative_shapecast: ShapeCast2D = _raycast_direction_map[relative_left_vector]
			left_relative_shapecast.force_shapecast_update()
			if not left_relative_shapecast.is_colliding():
				_direction = relative_left_vector
				_update_animation()
			else:
				_direction = - _direction
				_update_animation()
	else:
		var snapped_position: Vector2 = snapped(global_position, Vector2(Globals.TILE_SIZE, Globals.TILE_SIZE) / 2)
		if is_zero_approx(fmod(snapped_position.x, Globals.TILE_SIZE)):
			var offset_mult = 1 if global_position.x > snapped_position.x else -1
			snapped_position.x += offset_mult * Globals.TILE_SIZE / 2.0
		if is_zero_approx(fmod(snapped_position.y, Globals.TILE_SIZE)):
			var offset_mult = 1 if global_position.y > snapped_position.y else -1
			snapped_position.y += offset_mult * Globals.TILE_SIZE / 2.0
		# Consider turning only close to the center of a tile.
		if global_position.distance_to(snapped_position) < 2.5 and _can_turn:
			_can_turn = false
			_turn_timer.start(0.25)

			# Get 3 directions, except back one.
			var possible_directions := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
			if _direction.is_equal_approx(Vector2.RIGHT):
				possible_directions.erase(Vector2.LEFT)
			elif _direction.is_equal_approx(Vector2.LEFT):
				possible_directions.erase(Vector2.RIGHT)
			elif _direction.is_equal_approx(Vector2.UP):
				possible_directions.erase(Vector2.DOWN)
			elif _direction.is_equal_approx(Vector2.DOWN):
				possible_directions.erase(Vector2.UP)

			# Check which directions are free.
			var possible_routes: Array[Vector2] = []
			for possible_direction in possible_directions:
				var shapecast: ShapeCast2D = _raycast_direction_map[possible_direction]
				shapecast.force_shapecast_update()
				if not shapecast.is_colliding():
					possible_routes.append(possible_direction)

			# It only makes sense to change the direction, if there is more than 1 option.
			if possible_routes.size() > 1:
				var picked_direction: Vector2 = possible_routes.pick_random()
				if picked_direction != _direction:
					_direction = picked_direction
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
