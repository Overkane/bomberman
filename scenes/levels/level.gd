class_name Level
extends Node2D

signal level_finished

const LEVEL_DOOR_SCENE = preload("uid://u1lrj0i8v7ll")
const BONUS_PICKUP_SCENE = preload("uid://dri4l3tofa24c")

@export var drop_table: Array = []
@export var _player_spawn_point: Marker2D

var level_door: LevelDoor
var current_enemy_amount: int = 0


func _ready() -> void:
	assert(_player_spawn_point != null, "Player spawn point must be assigned in the level.")

	var destructible_boxes: Array = get_tree().get_nodes_in_group(Globals.GROUP_DESTRUCTIBLE_BOXES)

	# All levels must have door scene for being able to complete the level.
	drop_table.append(LEVEL_DOOR_SCENE)
	if drop_table.size() > destructible_boxes.size():
		assert(false, "Drop table size cannot be larger than destructible boxes size.")

	# Check if need to fill drop table with null values for empty drops.
	if drop_table.size() < destructible_boxes.size():
		var empty_slots: int = destructible_boxes.size() - drop_table.size()
		for i in range(empty_slots):
			drop_table.append(null)

	for destructible_box: DestructibleBox in destructible_boxes:
		destructible_box.exploded.connect(func():
			drop_table.shuffle()
			var drop_table_item: Variant = drop_table.pop_back()

			if drop_table_item is BonusPickupsBase:
				var bonus_pickup: BonusPickup = BONUS_PICKUP_SCENE.instantiate()
				bonus_pickup.global_position = destructible_box.global_position
				bonus_pickup.icon = bonus_pickup.icon
				bonus_pickup.bonus_type = bonus_pickup.bonus_type
				add_child(bonus_pickup)
			elif drop_table_item is PackedScene:
				var level_object: Variant = drop_table_item.instantiate()
				level_object.global_position = destructible_box.global_position
				add_child(level_object)
				if level_object is LevelDoor:
					level_door = level_object

					if current_enemy_amount == 0:
						level_door.open_door()

					level_door.level_door_entered.connect(func():
						level_finished.emit()
					)
		)

	for enemy: Fool in get_tree().get_nodes_in_group(Globals.GROUP_ENEMIES):
		current_enemy_amount += 1
		enemy.exploded.connect(func():
			current_enemy_amount -= 1
			# Check if all enemies are killed to open the level door.
			if current_enemy_amount == 0 and level_door != null:
				level_door.open_door()
		)


func get_player_spawn_point() -> Vector2:
	return _player_spawn_point.global_position
