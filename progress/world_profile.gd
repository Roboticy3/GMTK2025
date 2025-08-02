class_name WorldProfile extends Node

#region loose
#loose objects to preseve between sessions. Mostly items in shelters
#they are also assumed to be direct children of the main scene.
@export var loose:Array[PackedScene] = []

func loose_cycle(tree:SceneTree, loose_group:StringName, safe_group:StringName):
	#clear fruit on the ground that are not in a shelter
	var safe:Dictionary[Node, Variant]
	for s in tree.get_nodes_in_group(safe_group):
		var overlapping:Array[Node2D] = s.get_overlapping_bodies()
		for o in overlapping:
			if o.is_in_group(loose_group):
				safe[o] = true
	
	for l in tree.get_nodes_in_group(loose_group):
		if safe.has(l): 
			var pack := PackedScene.new()
			pack.pack(l)
			loose.append(pack)
		else:
			l.queue_free()

func loose_reload(tree:SceneTree, loose_group:StringName):
	tree.call_group(loose_group, "free")
	for pack in loose:
		var l := pack.instantiate()
		tree.current_scene.add_child(l)
#endregion

@export var fruit_data := PickableProfile.new()
@export var spooear_data := PickableProfile.new()

func all_cycle_fail(tree:SceneTree):
	loose_reload(tree, &"Loose")
	fruit_data.spawn_cycle_fail(tree, &"FruitBranch", &"Fruit")
	spooear_data.spawn_cycle_fail(tree, &"SpooearSpawner", &"Spooear")

func all_cycle(tree:SceneTree):
	loose = []
	loose_cycle(tree, &"Loose", &"Shelter")
	loose_cycle(tree, &"SpearStuck", &"")
	fruit_data.spawn_cycle(tree, &"FruitBranch", &"Fruit")
	spooear_data.spawn_cycle(tree, &"SpooearSpawner", &"Spooear")

func all_reload(tree:SceneTree):
	loose_reload(tree, &"Loose")
	fruit_data.spawn_reload(tree, &"FruitBranch")
	spooear_data.spawn_reload(tree, &"SpooearSpawner")
