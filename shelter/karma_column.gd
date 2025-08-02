extends Node

@onready var profile := GameManager.profile
@onready var world_profile := GameManager.world_profile

@export var karma_column:Control

func _ready():
	var start_pos := karma_to_position(profile.current_karma)
	karma_column.position.x = start_pos.y

var ending_state := &""
func change_karma(ending:StringName):
	
	ending_state = ending
	match ending:
		&"Success": 
			profile.current_karma = profile.current_karma + 1
		&"Fail": 
			#negate a fail if player is in shelter.
			for s in get_tree().get_nodes_in_group(&"Shelter"):
				if s.captive and s.captive.is_in_group(&"Player"):
					return
			profile.current_karma = profile.current_karma + 0

	$AnimationPlayer.play("update_karma")

func change_karma_bar_position():
	var karma := profile.current_karma
	var final_pos := karma_to_position(karma)
	
	print("moving ", karma_column, " to ", final_pos)
	var tween := karma_column.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(karma_column, "position:x", final_pos.y - 12.0, 3.0)
	var second := tween.chain()
	second.tween_property(karma_column, "position:x", final_pos.y, 1.0)
	second.tween_callback(next_cycle)
	
func karma_to_position(k:int) -> Vector2:
	return Vector2(0.0, 64.0 * k - 160.0)

func next_cycle():
	match ending_state:
		&"Success": 
			GameManager.set_player_spawn()
			profile.current_food -= 4
			world_profile.all_cycle(get_tree())
		&"Fail": 
			profile.current_food = profile.current_food_at_cycle
			world_profile.all_cycle_fail(get_tree())
	
	profile.current_food_at_cycle = profile.current_food
	GameManager.next_cycle()
