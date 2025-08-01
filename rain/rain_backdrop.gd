extends AnimatedSprite2D

@export var shaking_intensity := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.rain_started.connect(func ():
		play("rain")
		$AnimationPlayer.play("rain")
	)
	
func _process(delta: float) -> void:
	offset = Vector2.from_angle(randi_range(0, 2 * PI)) * shaking_intensity
