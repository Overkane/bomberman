extends Node2D

const BONUS_PICKUP_SCENE = preload("uid://dri4l3tofa24c")

@export var drop_table: Array[BonusPickupsBase] = []


func _ready() -> void:
	var destructible_boxes: Array = get_tree().get_nodes_in_group(&"destructible_boxes")

	# Check if need to fill drop table with null values for empty drops.
	if drop_table.size() < destructible_boxes.size():
		var empty_slots: int = destructible_boxes.size() - drop_table.size()
		for i in range(empty_slots):
			drop_table.append(null)

	for destructible_box: DestructibleBox in destructible_boxes:
		destructible_box.exploded.connect(func():
			drop_table.shuffle()
			var bonus: BonusPickupsBase = drop_table.pop_back()
			if bonus != null:
				var bonus_pickup: BonusPickup = BONUS_PICKUP_SCENE.instantiate()
				bonus_pickup.global_position = destructible_box.global_position
				bonus_pickup.icon = bonus.icon
				bonus_pickup.bonus_type = bonus.bonus_type
				get_tree().root.add_child(bonus_pickup)
		)
