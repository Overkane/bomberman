class_name PermanentBonusCard
extends AspectRatioContainer

signal card_selected(bonus_type: BonusHandler.BonusType)

var _icon: Texture2D
var _description: String
var _bonus_type: BonusHandler.BonusType

@onready var _card_button: TextureButton = %CardButton
@onready var _card_description: Label = %CardDescription


func _ready() -> void:
	_card_button.pressed.connect(func() -> void:
		card_selected.emit(_bonus_type)
	)
	_card_button.texture_normal = _icon
	_card_description.text = _description


func init(bonus_pickup_resource: BonusPickupsBase) -> void:
	_icon = bonus_pickup_resource.icon
	_description = bonus_pickup_resource.description
	_bonus_type = bonus_pickup_resource.bonus_type
