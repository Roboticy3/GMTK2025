extends AudioStreamPlayer2D

@export var player:CharacterBody2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player.walking or player.tunneling) and !playing:
		playing = true
	else:
		playing = false
