class_name Level
extends Node2D

signal level_finished

const _LEVEL_DOOR_SCENE = preload("uid://u1lrj0i8v7ll")
const _BONUS_PICKUP_SCENE = preload("uid://dri4l3tofa24c")

@export var _bonus_drop_table: Array[BonusPickupsBase] = []

var _player_spawn_point: Marker2D
var _final_drop_table: Array = []
var _level_door: LevelDoor
var _current_enemy_amount: int = 0


func _ready() -> void:
	_player_spawn_point = get_tree().get_first_node_in_group(Globals.GROUP_PLAYER_SPAWNERS)
	assert(_player_spawn_point != null, "Player spawn point must be assigned in the level.")

	var destructible_boxes: Array = get_tree().get_nodes_in_group(Globals.GROUP_DESTRUCTIBLE_BOXES)

	_final_drop_table.append_array(_bonus_drop_table)

	# All levels must have door scene for being able to complete the level.
	_final_drop_table.append(_LEVEL_DOOR_SCENE)

	if _final_drop_table.size() > destructible_boxes.size():
		assert(false, "Drop table size cannot be larger than destructible boxes size.")

	# Check if need to fill drop table with null values for empty drops.
	if _final_drop_table.size() < destructible_boxes.size():
		var empty_slots: int = destructible_boxes.size() - _final_drop_table.size()
		for i in range(empty_slots):
			_final_drop_table.append(null)

	for destructible_box: DestructibleBox in destructible_boxes:
		destructible_box.exploded.connect(func():
			_final_drop_table.shuffle()
			var drop_table_item: Variant = _final_drop_table.pop_back()

			if drop_table_item is BonusPickupsBase:
				var bonus_pickup: BonusPickup = _BONUS_PICKUP_SCENE.instantiate()
				bonus_pickup.global_position = destructible_box.global_position
				bonus_pickup.icon = drop_table_item.icon
				bonus_pickup.description = drop_table_item.description
				bonus_pickup.bonus_type = drop_table_item.bonus_type
				add_child(bonus_pickup)
			elif drop_table_item is PackedScene:
				var level_object: Variant = drop_table_item.instantiate()
				level_object.global_position = destructible_box.global_position
				add_child(level_object)
				if level_object is LevelDoor:
					_level_door = level_object

					if _current_enemy_amount == 0:
						_level_door.open_door()

					_level_door.level_door_entered.connect(func():
						level_finished.emit()
					)
		)

	for enemy in get_tree().get_nodes_in_group(Globals.GROUP_ENEMIES):
		_current_enemy_amount += 1
		enemy.exploded.connect(func():
			_current_enemy_amount -= 1
			# Check if all enemies are killed to open the level door.
			if _current_enemy_amount == 0 and _level_door != null:
				_level_door.open_door()
		)


func get_player_spawn_point() -> Vector2:
	return _player_spawn_point.global_position
