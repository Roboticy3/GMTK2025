extends Node

@onready var profile := GameManager.profile
@onready var world_profile := GameManager.world_profile

@export var karma_column:Control

func _ready():
	var start_pos := karma_to_position(profile.current_karma)
	karma_column.position.x = start_pos.y

func change_karma(ending:StringName):
	
	match ending:
		&"Success": profile.current_karma = profile.current_karma + 1
		&"Fail": profile.current_karma = profile.current_karma + 0

	$AnimationPlayer.play("update_karma")

func change_karma_bar_position():
	var karma := profile.current_karma
	var final_pos := karma_to_position(karma)
	
	print("moving ", karma_column, " to ", final_pos)
	var tween := karma_column.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(karma_column, "position:x", final_pos.y, 3.0)
	var second := tween.chain()
	second.tween_property(karma_column, "position:x", final_pos.y, 1.0)
	second.tween_callback(next_cycle)
	
func karma_to_position(k:int) -> Vector2:
	return Vector2(0.0, 64.0 * k - 160.0)

func next_cycle():
	profile.current_food -= 4
	world_profile.all_cycle(get_tree())
	
