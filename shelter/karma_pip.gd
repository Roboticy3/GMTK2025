extends Sprite2D

@onready var profile := GameManager.profile

@export var atlas:AtlasTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	profile.current_karma_changed.connect(_on_karma_changed)

func _on_karma_changed(k:int) -> void:
	atlas.region.position.x = 64 * (profile.max_karma - k)
