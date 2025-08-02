extends Area2D

var captive:CharacterBody2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("Shelter")

signal success()
signal fail()
func _on_body_entered(body:Node):

	if body.is_in_group(&"Player"):
		
		if GameManager.profile.current_food >= GameManager.profile.food_needed:
			captive = body
			$AnimationPlayer.stop()
			$AnimationPlayer.play("close")
			success.emit()
		else:
			fail.emit()

func _on_body_exited(body:Node):
	if body == captive and $AnimationPlayer.current_animation_position < 2.6:
		$AnimationPlayer.stop()
