extends AudioStreamPlayer

@onready var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer := Timer.new()
	
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(play_timed.bind(timer))
	
	add_child(timer)

func play_timed(timer):
	play()
	timer.wait_time = rng.randi_range(30, 150)
