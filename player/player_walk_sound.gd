extends AudioStreamPlayer2D

@export var player:CharacterBody2D

var should_play := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	should_play = !player.velocity.is_zero_approx() and (player.is_on_floor() or player.touching_rope_type != &"")

	if should_play and !playing:
		playing = true
		volume_db = -40.0
		create_tween().tween_property(self, "volume_db", 0.0, 1.0)
	elif !should_play and playing:
		playing = false
		
