extends Node

@onready var profile = GameManager.profile
@export var atlas:AtlasTexture

func set_karma(k:int) -> void:
	atlas.region.position.x = 64 * (profile.max_karma - k)
