class_name PermanentBonusChooser
extends Control

signal bonus_selected(bonus_type: BonusHandler.BonusType)

const _CARD_NUMBER := 2
const _PERMANENT_BONUS_CARD_SCENE := preload("uid://ctvae00raux8m")
const _BOMB_POWER_BONUS := preload("uid://dsfpxdabmgj2j")
const _MAX_BOMBS_BONUS := preload("uid://b3hpj6e4snkey")
const _ADDITIONAL_LIFE_BONUS := preload("uid://dhd2ohhdhm3ls")

const _POSSIBLE_PERMANENT_BONUSES: Array[BonusPickupsBase] = [
	_BOMB_POWER_BONUS,
	_MAX_BOMBS_BONUS,
	_ADDITIONAL_LIFE_BONUS,
]

@onready var _bonus_card_container: HBoxContainer = %BonusCardContainer
@onready var _confirm_button: Button = %ConfirmButton


func _ready() -> void:
	var current_bonus_list: Array[BonusPickupsBase] = _POSSIBLE_PERMANENT_BONUSES.duplicate()
	current_bonus_list.shuffle()

	# Remove stuff for testing in editor
	for child in _bonus_card_container.get_children():
		child.queue_free()

	for i in _CARD_NUMBER:
		var bonus_card: PermanentBonusCard = _PERMANENT_BONUS_CARD_SCENE.instantiate()
		bonus_card.init(current_bonus_list.pop_back())
		bonus_card.card_selected.connect(func(bonus_type: BonusHandler.BonusType) -> void:
			SoundManager.play_sound(SoundManager.SOUND_TYPE.POWERUP)
			bonus_selected.emit(bonus_type)
		)
		_bonus_card_container.add_child(bonus_card)
		if i == 0:
			bonus_card.grab_focus.call_deferred()

	_confirm_button.pressed.connect(func() -> void:
		var picked_card: PermanentBonusCard = get_viewport().gui_get_focus_owner()
		picked_card.pick()
	)
