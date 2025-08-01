class_name Item extends RigidBody2D

@export var glow_material:Material
@export var throw_strength := 1000.0
@export var food_points := 0

func set_glow(to:bool):
	if to: $Sprite2D.material = glow_material
	else: $Sprite2D.material = null

signal grabbed()
