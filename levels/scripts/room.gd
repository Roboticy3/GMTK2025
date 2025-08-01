extends Area2D

@export var collision_shape:CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("Player"):
		var cam := get_viewport().get_camera_2d()
		set_camera_bounds(cam)

func set_camera_bounds(cam:Camera2D):
	
	var local_rect := collision_shape.shape.get_rect()
	
	var top_left := collision_shape.global_transform * (local_rect.position)
	var bottom_right := collision_shape.global_transform * (local_rect.end)
	
	cam.limit_left = top_left.x
	cam.limit_top = top_left.y
	cam.limit_right = bottom_right.x
	cam.limit_bottom = bottom_right.y
