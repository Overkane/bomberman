class_name Player
extends CharacterBody2D

signal exploded

const BASE_SPEED := 150.0
const BASE_MAX_BOMBS := 1
const BOMB_SCENE := preload("uid://bpo5y5pvhbibe")
const INVULNERABILITY_TIME := 1.5

var _max_bombs: int:
	get():
		return BASE_MAX_BOMBS + BonusHandler.get_bonus(self, BonusHandler.BonusType.BOMB_COUNT)
var _current_bombs := 0
var _amount_of_lives := 3
var _is_invulnerable := false

@onready var enemy_hurtbox: Area2D = %EnemyHurtbox
@onready var invulnerability_timer: Timer = %InvulnerabilityTimer


func _ready() -> void:
	enemy_hurtbox.body_entered.connect(func(_body: Node) -> void:
		explode()
	)
	invulnerability_timer.timeout.connect(func() -> void:
		_is_invulnerable = false
		# If still inside the enemy during invulnerability, explode again.
		if enemy_hurtbox.has_overlapping_bodies():
			explode()
	)

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * BASE_SPEED
	move_and_slide()

func _input(event) -> void:
	if event.is_action_pressed(&"place_bomb") and _current_bombs < _max_bombs:
		_current_bombs += 1
		# TODO can't place several bombs in one place
		var bomb: Bomb = BOMB_SCENE.instantiate()
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
		get_tree().root.add_child(bomb)


func explode() -> void:
	if _is_invulnerable:
		return

	if _amount_of_lives > 0:
		_amount_of_lives -= 1
		if _amount_of_lives == 0:
			exploded.emit()
			queue_free()
		else:
			_is_invulnerable = true
			invulnerability_timer.start(INVULNERABILITY_TIME)
