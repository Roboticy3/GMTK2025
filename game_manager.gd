extends Node

#region serialization
#replace with loader
signal profile_changed
var profile := PlayerProfile.new() :
	set(new_profile):
		profile = new_profile
		profile_changed.emit()

signal world_profile_changed
var world_profile := WorldProfile.new() :
	set(new_world_profile):
		world_profile= new_world_profile
		world_profile_changed.emit()

func load_profiles():
	var test_p := load("user://profile.tres")
	if test_p is PlayerProfile:
		profile = test_p
	
	var test_w := load("user://world_profile.tres")
	if test_w is WorldProfile:
		world_profile = test_w
	
	if profile.shelter:
		get_current_player().global_position = \
		get_tree().current_scene.get_node(
			profile.shelter
		).global_position
		set_player_spawn()

func save_profiles():
	ResourceSaver.save(profile, "user://profile.tres")
	ResourceSaver.save(world_profile, "user://world_profile.tres")

#endregion

#region cycle
var cycle_timer:Timer
const START_CYCLE_TIME := 200.0
const MAX_CYCLE_TIME := 280.0
const MIN_CYCLE_TIME := 120.0

func _init():
	cycle_timer = Timer.new()
	cycle_timer.autostart = true
	cycle_timer.one_shot = false
	cycle_timer.wait_time = START_CYCLE_TIME
	cycle_timer.timeout.connect(rain)

signal cycle()
func next_cycle():
	
	#restart the timer
	cycle_timer.stop()
	cycle_timer.wait_time = randf_range(MIN_CYCLE_TIME, MAX_CYCLE_TIME)
	cycle_timer.start.call_deferred()
	
	spawn_player()
	
	
	
	cycle.emit()

signal rain_started()
func rain():
	rain_started.emit()

#endregion

func _ready():
	start()
	pass

func start():
	
	cycle_timer.stop()
	cycle_timer.reparent(self)

	const START := preload("res://levels/cereal_graveyard/cereal_graveyard.tscn")
	var old_scene := get_tree().current_scene
	get_tree().change_scene_to_packed(START)

	# Wait until current_scene changes
	while get_tree().current_scene == old_scene or !get_tree().current_scene:
		await get_tree().process_frame
	
	spawn_player()
	spawn_ui()
	
	while !is_instance_valid(get_current_player()):
		await get_tree().process_frame
	
	load_profiles()
	
	if reset: world_profile.all_deregister()
	world_profile.all_reload(get_tree())
	
	get_tree().current_scene.add_child(cycle_timer)
	cycle_timer.start()

#region spawnage

func spawn_player():
	var current_player = get_current_player()
	if is_instance_valid(current_player):
		current_player.get_node("Hand").drop_held()
		current_player.queue_free()
	
	await get_tree().process_frame
	
	const PLAYER := preload("res://player/player.tscn")
	var s := get_tree().current_scene
	
	var p := get_tree().get_first_node_in_group("PlayerSpawn")
	if is_instance_valid(p):
		var i := PLAYER.instantiate()
		i.controller = PlayerController
		i.global_position = p.global_position
		s.add_child(i)

func spawn_ui():
	const UI := preload("res://ui/ui.tscn")
	get_tree().current_scene.add_child(UI.instantiate())

func set_player_spawn():
	var player := get_current_player()
	var spawn := get_tree().get_first_node_in_group(&"PlayerSpawn")
	
	spawn.global_position = player.global_position
	if player.is_on_floor():
		spawn.global_position += player.get_floor_normal() * 10.0

#endregion

#region helpers
func get_current_player() -> CharacterBody2D:
	return get_tree().get_first_node_in_group(&"Player")

func get_current_shelter() -> NodePath:
	for s in get_tree().get_nodes_in_group(&"Shelter"):
		if s.captive == get_current_player():
			return s.get_path()
	return NodePath("")
#endregion

#region debug
var reset = false

func profile_reset():
	reset = true
	profile = PlayerProfile.new()
	world_profile = WorldProfile.new()
	save_profiles()
	start()
	reset = false

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("delete"):
		#spawn reset menu, and reset on confirm
		var RESET_MENU := preload("res://settings/are_you_sure.tscn")
		var r := RESET_MENU.instantiate()
		get_tree().current_scene.add_child(r)
		r.pipe.connect(profile_reset)
	
	if OS.has_feature("editor") and event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_1:
			profile.current_food = profile.max_food
		elif event.keycode == KEY_2:
			next_cycle()
		elif event.keycode == KEY_3:
			get_tree().call_group(
				&"Player", &"set_deferred", &"global_position", 
				get_tree().get_first_node_in_group(&"Shelter").global_position
			)
		elif event.keycode == KEY_4:
			set_player_spawn()
			spawn_player()
		elif event.keycode == KEY_5:
			var camera := get_viewport().get_camera_2d()
			var player := get_tree().get_first_node_in_group(&"Player")
			if player.is_ancestor_of(camera):
				camera.reparent(get_tree().current_scene)
			else:
				camera.reparent(player)
				camera.position = Vector2.ZERO
		elif event.keycode == KEY_6:
			profile = PlayerProfile.new()
			world_profile = WorldProfile.new()
			save_profiles()
		elif event.keycode == KEY_7:
			var s := get_tree().get_first_node_in_group(&"Spooear")
			if s is Spooear:
				get_current_player().global_position = s.global_position
				get_viewport().get_camera_2d().position = Vector2.ZERO
			else:
				printerr("No spears in the world!!")

#endregion
