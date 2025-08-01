extends Node

@onready var profile := GameManager.profile

@export var atlas:AtlasTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	profile.current_karma_changed.connect(_on_karma_changed)

func _on_karma_changed(k:int) -> void:
	get_tree().create_timer(8.0).timeout.connect(func ():
		atlas.region.position.x = 64 * (profile.max_karma - k)
	)
