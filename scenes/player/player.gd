class_name Player
extends CharacterBody2D

signal exploded

const _BASE_SPEED := 150.0
const _BASE_MAX_LIVES := 1
const _BASE_MAX_BOMBS := 1
const _BASE_BOMB_POWER := 1
const _BOMB_SCENE := preload("uid://bpo5y5pvhbibe")
const _INVULNERABILITY_TIME := 1.5

var _max_bombs: int:
	get():
		return _BASE_MAX_BOMBS + BonusHandler.get_bonus(self, BonusHandler.BonusType.BOMB_COUNT)
var _current_bombs := 0
var _bomb_power: int:
	get():
		return _BASE_BOMB_POWER + BonusHandler.get_bonus(self, BonusHandler.BonusType.BOMB_POWER)
var _lives_wasted := 0
var _amount_of_lives: int:
	get():
		return _BASE_MAX_LIVES + BonusHandler.get_bonus(self, BonusHandler.BonusType.ADDITIONAL_LIFE) - _lives_wasted
var _is_invulnerable := false
var _is_dead := false

@onready var _enemy_hurtbox: Area2D = %EnemyHurtbox
@onready var _invulnerability_timer: Timer = %InvulnerabilityTimer
@onready var _bomb_placement_checker: Area2D = %BombPlacementChecker


func _ready() -> void:
	_enemy_hurtbox.body_entered.connect(func(_body: Node) -> void:
		explode()
	)
	_invulnerability_timer.timeout.connect(func() -> void:
		_is_invulnerable = false
		# If still inside the enemy during invulnerability, explode again.
		if _enemy_hurtbox.has_overlapping_bodies():
			explode()
	)

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return

	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * _BASE_SPEED

	move_and_slide()

func _input(event) -> void:
	if _is_dead:
		return

	if event.is_action_pressed(&"place_bomb") \
		and _bomb_placement_checker.get_overlapping_bodies().size() == 0 \
		and _current_bombs < _max_bombs:
		_current_bombs += 1
		# TODO can't place several bombs in one place
		var bomb: Bomb = _BOMB_SCENE.instantiate()
		bomb.init(_bomb_power)
		bomb.exploded.connect(func(): _current_bombs -= 1)
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
		add_sibling(bomb)


func explode() -> void:
	if _is_invulnerable or _is_dead:
		return

	if _amount_of_lives > 0:
		_lives_wasted += 1
		if _amount_of_lives == 0:
			_is_dead = true
			var tween = create_tween()
			tween.tween_method(_set_percent, 1.0, 0.0, 0.85)
			await tween.finished
			queue_free()
			exploded.emit()
			BonusHandler.clear_all_bonuses()
		else:
			_is_invulnerable = true
			_invulnerability_timer.start(_INVULNERABILITY_TIME)


func _set_percent(percentage: float) -> void:
	material.set_shader_parameter('percentage', percentage)
