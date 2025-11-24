class_name BonusPickup
extends Area2D

var icon: Texture2D
var description: String
var bonus_type: BonusHandler.BonusType

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var bonus_pickup_message: Label = %BonusPickupMessage


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite_2d.texture = icon
	bonus_pickup_message.text = description


func _on_body_entered(body: Node):
	BonusHandler.apply_bonus(body, bonus_type)
	SoundManager.play_sound(SoundManager.SoundType.POWERUP)

	# TODO implement better solution to remove bonus messages.
	bonus_pickup_message.reparent(get_parent()) # Will be removed with the parent - level.
	bonus_pickup_message.show()
	var tween = get_tree().create_tween()
	tween.tween_property(bonus_pickup_message, "position:y", position.y - 50, 1.25)
	tween.set_parallel()
	tween.tween_property(bonus_pickup_message, "self_modulate:a", 0, 1.25)
	queue_free()
