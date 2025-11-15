class_name BombExplosion
extends Area2D

@onready var explosion_lifetime_timer: Timer = $ExplosionLifetimeTimer


func _ready() -> void:
	explosion_lifetime_timer.timeout.connect(_on_explosion_lifetime_timeout)


func _on_explosion_lifetime_timeout() -> void:
	queue_free()
