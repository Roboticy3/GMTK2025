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
	
	loose = []
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

#region fruit
# A set of fruits and their ages. 0 if undisturbed. 1 if eaten or lost
# At the beginning of each cycle, remove all fruits, rebranch all zeroes,
# and respawn all older fruits with a probability dependent on age.
@export var fruit_branches: Dictionary[NodePath, int] = {}
const FRUIT_SPAWN_PROBABILITIES: PackedFloat32Array = [
	1.0,
	0.01,
	0.1,
	1.0
]

func get_fruit_branch_probability(branch:NodePath) -> float:
	var age = fruit_branches.get(branch)
	if age is int:
		age = clampi(age, 0, FRUIT_SPAWN_PROBABILITIES.size()-1)
		return FRUIT_SPAWN_PROBABILITIES[age]
	return FRUIT_SPAWN_PROBABILITIES[0]

func register_fruit_branches(tree:SceneTree, branch_group:StringName) -> void:
	for s in tree.get_nodes_in_group(branch_group):
		var branch := s.get_path()
		if !fruit_branches.has(branch):
			fruit_branches[branch] = 0
		
		if !s.has_connections("cut"):
			s.connect("cut", _on_branch_cut.bind(branch))

#kill a fruit
func _on_branch_cut(branch:NodePath) -> void:
	fruit_branches[branch] = 1

#called at the start of each cycle
func fruit_cycle(tree:SceneTree, branch_group:StringName, fruit_group:StringName) -> void:
		
	register_fruit_branches(tree, branch_group)
	
	#try to spawn each fruit on random chance
	#if chance fails, age the branch
	var rng := RandomNumberGenerator.new()
	for s in tree.get_nodes_in_group(branch_group):
		var branch := s.get_path()
		var p := get_fruit_branch_probability(branch)
		var r := rng.randf_range(0.0, 1.0)
		if r <= p:
			s.spawn()
			fruit_branches[branch] = 0
		else:
			fruit_branches[branch] += 1

#run on game load to register fruit branches
func fruit_reload(tree:SceneTree, branch_group:StringName) -> void:
	register_fruit_branches(tree, branch_group)
	for s in tree.get_nodes_in_group(branch_group):
		var branch := s.get_path()
		if fruit_branches.get(branch) == 0:
			s.spawn()
#endregion

func all_cycle(tree:SceneTree):
	loose_cycle(tree, &"Loose", &"Shelter")
	fruit_cycle(tree, &"FruitBranch", &"Fruit")

func all_reload(tree:SceneTree):
	loose_reload(tree, &"Loose")
	fruit_reload(tree, &"FruitBranch")
