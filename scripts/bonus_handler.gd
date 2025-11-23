class_name BonusHandler
extends Node

enum BonusType {
	BOMB_COUNT = 1,
	BOMB_POWER = 2,
	ADDITIONAL_LIFE = 3,
}

enum BonusCalculationType {
	NONE = 1,
	ADDITIVE = 2,
}

static var _bonus_map: Dictionary[Node, Array] = {}
static var _bonus_calculation_type: Dictionary[BonusType, BonusCalculationType] = {
	BonusType.BOMB_COUNT: BonusCalculationType.ADDITIVE,
	BonusType.BOMB_POWER: BonusCalculationType.ADDITIVE,
	BonusType.ADDITIONAL_LIFE: BonusCalculationType.ADDITIVE,
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

static func clear_temporary_bonuses() -> void:
	for entity in _bonus_map.keys():
		_bonus_map[entity] = _bonus_map[entity].filter(func(bonus: Bonus) -> bool:
			return bonus.is_permanent
		)


class Bonus:
	var type: BonusType
	var is_permanent: bool
