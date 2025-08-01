extends Node

@onready var profile := GameManager.profile

@export var karma_column:VBoxContainer

func _ready():
	var start_pos := karma_to_position(profile.current_karma)
	karma_column.position.y = start_pos.y

func change_karma(ending:StringName):
	
	match ending:
		&"Success": profile.current_karma = profile.current_karma + 1
		&"Fail": profile.current_karma = profile.current_karma + 0
	
	var karma := profile.current_karma
	var final_pos := karma_to_position(karma)
	
	var tween := karma_column.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(karma_column, "position:y", final_pos.y, 3.0)
	var second := tween.chain()
	second.tween_property(karma_column, "position:y", final_pos.y, 1.0)
	
func karma_to_position(k:int) -> Vector2:
	return Vector2(0.0, 64.0 * k - 128.0)
