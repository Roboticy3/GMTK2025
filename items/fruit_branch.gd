extends Node

@export var fruit:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn()
	pass

func spawn():
	var f := fruit.instantiate()
	if !(f is Fruit):
		printerr("fruit scene ", fruit, " does not have root of type Fruit!")
		return
	
	f.position = Vector2(0, 40.0)
	
	add_child(f)
	f.cut.connect($PinJoint2D.queue_free)
	f.cut.connect($Rope.reparent.bind(self))
	f.grabbed.connect($PinJoint2D.queue_free)
	f.grabbed.connect($Rope.reparent.bind(self))
	
	$Rope.reparent(f)
	$PinJoint2D.node_b = "../" + f.name
