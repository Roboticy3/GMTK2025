extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.rain_started.connect($AnimationPlayer.play.bind("rain"))
	GameManager.cycle.connect(func ():
		if $AnimationPlayer.is_playing():
			return
		$AnimationPlayer.play.bind("cycle")
	)
