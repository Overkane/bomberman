class_name BonusPickup
extends Area2D

var icon: Texture2D
var bonus_type: BonusHandler.BonusType

@onready var sprite_2d: Sprite2D = %Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite_2d.texture = icon


func _on_body_entered(body: Node):
	BonusHandler.apply_bonus(body, bonus_type)
	queue_free()
