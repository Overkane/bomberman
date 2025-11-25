class_name Enemy
extends CharacterBody2D

signal exploded

@export_enum("Right:0", "Up:1", "Left:2", "Down:3") var _initial_direction_id: int

@export var _speed: float = 50.0

var _direction: Vector2
var _is_dead := false

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_direction = VectorUtils.VECTOR_LIST[_initial_direction_id]
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
