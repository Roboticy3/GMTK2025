extends Area2D

var captive:CharacterBody2D

@onready var profile = GameManager.profile

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("Shelter")

signal success()
signal fail()
func _on_body_entered(body:Node):

	if body.is_in_group(&"Player"):
		
		if profile.current_food >= profile.food_needed:
			captive = body
			$AnimationPlayer.stop()
			$AnimationPlayer.play("close")
			success.emit()
		else:
			fail.emit()
