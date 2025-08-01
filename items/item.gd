class_name Item extends RigidBody2D

@export var glow_material:Material
@export var throw_strength := 1000.0
@export var food_points := 0

func set_glow(to:bool):
	if to: $Sprite2D.material = glow_material
	else: $Sprite2D.material = null

func _on_throw():
	var shape := $CollisionShape2D
	shape.scale = Vector2.ONE * 3.0
	var tween := shape.create_tween()
	tween.tween_property(shape, "scale", Vector2.ONE, 0.4)

signal grabbed()
