extends Node2D

@export var character:CharacterBody2D
@export var sprite:Sprite2D

@export var rotation_speed := 0.0
var rotaion_from_speed := 0.0

@export var base_rotation := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite.flip_h = character.velocity.x <= 0.0
	
	if character.is_on_floor():
		var normal := character.get_floor_normal()
		base_rotation = Vector2.UP.angle_to(normal)
		
	rotaion_from_speed += rotation_speed * delta
	
	sprite.rotation = base_rotation + rotaion_from_speed

	
	
