class_name BombExplosion
extends Area2D

@onready var _explosion_lifetime_timer: Timer = $ExplosionLifetimeTimer


func _ready() -> void:
	_explosion_lifetime_timer.timeout.connect(_on_explosion_lifetime_timeout)
	body_entered.connect(_on_body_entered)
	SoundManager.play_sound(SoundManager.SOUND_TYPE.BOOM)


func _on_body_entered(body: Node) -> void:
	assert(body.has_method("explode"), "Body does not have an explode() method")
	body.call_deferred("explode")
	if body is DestructibleBox:
		queue_free()


func _on_explosion_lifetime_timeout() -> void:
	queue_free()
