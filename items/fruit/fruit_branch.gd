extends Node

@export var fruit:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spawn()
	add_to_group(&"FruitBranch")
	pass

#pass the cut signal up to the world
#RESERVED for use by the world
signal cut()

var spawned := false
func spawn():
	if spawned:
		return
	
	var f := fruit.instantiate()
	if !(f is Fruit):
		printerr("fruit scene ", fruit, " does not have root of type Fruit!")
		return
	
	$Rope.rotation = 0.0
	
	f.position = Vector2(0, 40.0)
	f.collision_layer |= 2
	f.collision_mask |= 2
	
	add_child(f)
	f.cut.connect($PinJoint2D.set_node_b.bind(""))
	f.cut.connect($Rope.reparent.bind(self))
	f.cut.connect(cut.emit)
	f.cut.connect(set.bind("spawned", false))
	f.cut.connect(func ():
		f.collision_layer &= ~(2)
		f.collision_mask &= ~(2)
	)
	f.grabbed.connect(f.cut.emit)
	
	$Rope.reparent(f)
	$PinJoint2D.node_b = "../" + f.name
	
	spawned = true
