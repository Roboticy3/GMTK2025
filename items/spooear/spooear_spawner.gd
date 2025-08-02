extends Node

@export var spooear:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spawn()
	add_to_group(&"SpooearSpawner")
	pass

#pass the cut signal up to the world
#RESERVED for use by the world
signal cut()

var spawned := false
func spawn():
	if spawned:
		return
	
	var s := spooear.instantiate()
	if !(s is Spooear):
		printerr("spooear scene ", spooear, " does not have root of type Spooear!")
		return
	
	s.rotation = -PI * .5
	
	add_child(s)
	s.grabbed.connect(cut.emit)
	s.grabbed.connect(set.bind("spawned", false))
	
	spawned = true
