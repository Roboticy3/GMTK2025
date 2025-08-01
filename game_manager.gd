extends Node

var current_room:Node
var current_player:CharacterBody2D

var ui:PackedScene

#replace with loader
var profile := PlayerProfile.new()
var world_profile := WorldProfile.new()

var cycle_timer:Timer

func _init():
	cycle_timer = Timer.new()
	cycle_timer.autostart = true
	cycle_timer.one_shot = false
	cycle_timer.wait_time = 180.0

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

func next_cycle():
	profile.current_food -= 4
	world_profile.all_cycle(get_tree())
	
	#restart the timer
	cycle_timer.stop()
	cycle_timer.wait_time = randf_range(150.0, 210.0)
	cycle_timer.start.call_deferred()

func _input(event: InputEvent) -> void:
	if OS.has_feature("editor") and event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_1:
			profile.current_food = profile.max_food
		elif event.keycode == KEY_2:
			next_cycle()
