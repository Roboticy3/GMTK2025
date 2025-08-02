extends Node

var current_room:Node
var current_player:CharacterBody2D

var ui:PackedScene

#replace with loader
var profile := PlayerProfile.new()
var world_profile := WorldProfile.new()

var cycle_timer:Timer
const START_CYCLE_TIME := 1.0
const MAX_CYCLE_TIME := 230.0
const MIN_CYCLE_TIME := 70.0

func _init():
	cycle_timer = Timer.new()
	cycle_timer.autostart = true
	cycle_timer.one_shot = false
	cycle_timer.wait_time = START_CYCLE_TIME
	cycle_timer.timeout.connect(rain)

func _ready():
	start()
	pass

func start():

	const START := preload("res://levels/cereal_graveyard/cereal_graveyard.tscn")
	var old_scene := get_tree().current_scene
	get_tree().change_scene_to_packed(START)

	# Wait until current_scene changes
	while get_tree().current_scene == old_scene:
		await get_tree().process_frame
	
	spawn_player()
	spawn_ui()
	world_profile.all_reload(get_tree())
	
	add_child(cycle_timer)

func spawn_player():
	get_tree().call_group(&"Player", &"queue_free")
	
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

func set_player_spawn():
	var player := get_tree().get_first_node_in_group(&"Player")
	var spawn := get_tree().get_first_node_in_group(&"PlayerSpawn")
	
	spawn.global_position = player.global_position
	if player.is_on_floor():
		spawn.global_position += player.get_floor_normal() * 10.0

func _input(event: InputEvent) -> void:
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
