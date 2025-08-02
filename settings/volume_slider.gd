extends Slider

@export var bus:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	min_value = -12.0
	max_value = 12.0
	value = 0.0
	step = 0.0
	value_changed.connect(_on_value_changed)

func _on_value_changed(to:float):
	AudioServer.set_bus_volume_db(bus, to)
