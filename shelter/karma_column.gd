extends Node

@export var karma_column:Control

func _ready():
	GameManager.profile_changed.connect(reconnect)

func reconnect():
	var start_pos := karma_to_position(GameManager.profile.current_karma)
	karma_column.position.x = start_pos.y

var ending_state := &""
func change_karma(ending:StringName):
	
	ending_state = ending
	match ending:
		&"Success": 
			GameManager.profile.current_karma = GameManager.profile.current_karma + 1
		&"Fail": 
			#negate a fail if player is in shelter.
			if GameManager.get_current_shelter():
				return
			GameManager.profile.current_karma = GameManager.profile.current_karma + 0

	$AnimationPlayer.play("update_karma")

func change_karma_bar_position():
	var karma := GameManager.profile.current_karma
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
			GameManager.profile.current_food -= 4
			var shelter_path := GameManager.get_current_shelter()
			if shelter_path:
				GameManager.profile.shelter = shelter_path
			GameManager.world_profile.all_cycle(get_tree())
		&"Fail": 
			GameManager.profile.current_food = GameManager.profile.current_food_at_cycle
			GameManager.world_profile.all_cycle_fail(get_tree())
	
	GameManager.profile.current_food_at_cycle = GameManager.profile.current_food
	GameManager.next_cycle()
	
	#only save game on a successful cycle
	if ending_state == &"Success":
		GameManager.save_profiles()
