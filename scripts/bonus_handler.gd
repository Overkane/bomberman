class_name BonusHandler
extends Node

enum BonusType {
	BOMB_COUNT,
}

enum BonusCalculationType {
	NONE,
	ADDITIVE,
}

static var _bonus_map: Dictionary[Node, Array] = {}
static var _bonus_calculation_type: Dictionary[BonusType, BonusCalculationType] = {
	BonusType.BOMB_COUNT: BonusCalculationType.ADDITIVE,
}


static func apply_bonus(entity: Node, bonus_type: BonusType, is_permanent: bool = false) -> void:
	var bonus = Bonus.new()
	bonus.type = bonus_type
	bonus.is_permanent = is_permanent

	if not _bonus_map.has(entity):
		_bonus_map[entity] = []
	_bonus_map[entity].append(bonus)

static func get_bonus(entity: Node, bonus_type: BonusType) -> Variant:
	if not _bonus_map.has(entity):
		return 0

	var calculation_type: BonusCalculationType = _bonus_calculation_type.get(bonus_type)

	if calculation_type == BonusCalculationType.ADDITIVE:
		var count: int = 0
		for bonus in _bonus_map[entity]:
			if bonus.type == bonus_type:
				count += 1
		return count
	elif calculation_type == BonusCalculationType.NONE:
		for bonus in _bonus_map[entity]:
			if bonus.type == bonus_type:
				return bonus
	else:
		assert(false, "Unknown bonus calculation type: %s" % str(calculation_type))
		return null

	return null


class Bonus:
	var type: BonusType
	var is_permanent: bool
