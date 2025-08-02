extends Node

@export var atlas:AtlasTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reconnect()
	GameManager.profile_changed.connect(reconnect)

func reconnect():
	_on_karma_changed(GameManager.profile.current_karma)
	GameManager.profile.current_karma_changed.connect(_on_karma_changed)

func _on_karma_changed(k:int) -> void:
	get_tree().create_timer(8.0).timeout.connect(func ():
		atlas.region.position.x = 64 * (GameManager.profile.max_karma - k)
	)
