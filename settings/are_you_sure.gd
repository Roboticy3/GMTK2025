extends Node

signal pipe()
func _pass_pipe():
	pipe.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("delete"):
		queue_free()
