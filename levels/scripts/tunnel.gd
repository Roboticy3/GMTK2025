class_name Tunnel extends Area2D

@export var exit:Tunnel

var unpacked_room:Node

func _ready():
	add_to_group("Tunnels")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body:Node2D):
	if body.is_in_group("Entity"):
		if !is_instance_valid(unpacked_room):
			printerr("Room should be loaded by now!")
			return
		#move entity through the tunnel
		
		
		
