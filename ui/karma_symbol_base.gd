extends Node

@export var atlas:AtlasTexture

func set_karma(k:int) -> void:
	atlas.region.position.x = 64 * (GameManager.profile.max_karma - k)
