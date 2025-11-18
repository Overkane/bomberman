class_name Globals
extends Node

enum CollisionLayer {
	WORLD = 1,
	PLAYER = 2,
	EXPLODABLE = 3,
	BOMB_FOR_PLAYER = 10,
	BOMB_FOR_ENEMIES = 11,
	BOX_FOR_PLAYER = 15,
	BOX_FOR_ENEMIES = 16,
}

const TILE_SIZE := 32
