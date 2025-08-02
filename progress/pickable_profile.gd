class_name PickableProfile extends Resource

# A set of fruits and their ages. 0 if undisturbed. 1 if eaten or lost
# At the beginning of each cycle, remove all fruits, respawner all zeroes,
# and respawn all older fruits with a probability dependent on age.
@export var spawners: Dictionary[NodePath, int] = {}
@export var age_probabilities: PackedFloat32Array = [
	1.0,
	0.01,
	0.1,
	1.0
]

func get_spawner_probability(spawner:NodePath) -> float:
	var age = spawners.get(spawner)
	if age is int:
		age = clampi(age, 0, age_probabilities.size()-1)
		return age_probabilities[age]
	return age_probabilities[0]

func register_spawners(tree:SceneTree, spawner_group:StringName) -> void:
	for s in tree.get_nodes_in_group(spawner_group):
		var spawner := s.get_path()
		if !spawners.has(spawner):
			spawners[spawner] = 0
		
		if !s.has_connections("cut"):
			s.connect("cut", _on_spawner_cut.bind(spawner))

#kill a fruit
func _on_spawner_cut(spawner:NodePath) -> void:
	spawners[spawner] = 1

#called at the start of each cycle
func spawn_cycle(tree:SceneTree, spawner_group:StringName) -> void:
		
	register_spawners(tree, spawner_group)
	
	#try to spawn each fruit on random chance
	#if chance fails, age the spawner
	var rng := RandomNumberGenerator.new()
	for s in tree.get_nodes_in_group(spawner_group):
		var spawner := s.get_path()
		var p := get_spawner_probability(spawner)
		var r := rng.randf_range(0.0, 1.0)
		if r <= p:
			s.spawn()
			spawners[spawner] = 0
		else:
			spawners[spawner] += 1

#Like spawn cycle, but respawns all age 1 (freshly collected) items instead of 
#	random items, and does not update age counts
func spawn_cycle_fail(tree:SceneTree, spawner_group:StringName) -> void:
	register_spawners(tree, spawner_group)
	
	for s in tree.get_nodes_in_group(spawner_group):
		var spawner := s.get_path()
		if spawners.get(spawner) == 1:
			s.spawn()
			spawners[spawner] = 0

func spawn_deregister():
	spawners = {}
