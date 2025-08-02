class_name Fruit extends Item

@export var hues:Array[Color] = [
	Color("#DA291C"),
	Color("#F57F17"),
	Color("#FEE101"),
	Color("#7AC143"),
	Color("#0072CE"),
	Color("#92278F"),
]

func _ready():
	var rng := RandomNumberGenerator.new()
	modulate = hues[rng.randi_range(0, 5)]
	add_to_group(&"Fruit")
	
	cut.connect(add_to_group.bind(&"Loose"))

signal cut()
func _on_body_entered(body: Node) -> void:
	if body is Item and body.linear_velocity.length() > 150.0:
		body.linear_velocity *= -0.2
		cut.emit()
