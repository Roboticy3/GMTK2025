class_name Spooear extends Item


# Called when the node enters the scene tree for the first time.

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	gravity_scale = 1.0 / (1.0 + linear_velocity.length() * 0.01)

func _on_body_entered(body:Node):
	if body is TileMapLayer:
		try_stick(body)
	super._on_body_entered(body)
	time_in_air = 0.0

func try_stick(body:TileMapLayer):
	if time_in_air >= 0.3:
		return
	
	var cell_forward := body.local_to_map(
		body.to_local(global_position + global_transform.x * 16.0)
	)
	var tile = body.get_cell_tile_data(cell_forward)
	
	var cell_over := body.local_to_map(
		body.to_local(global_position)
	)
	var tile_over = body.get_cell_tile_data(cell_over)
	
	#Hack. Assume terrain id zero is penetrable
	#	This should be done with a duplicate physics layer(?)
	#		I'm not really sure
	if tile is TileData and !(tile_over is TileData) and tile.terrain <= 0:
		stick()

#freeze the spear and make it climbable
func stick():
	print("sticking item")
	stuck = true
	set_process(false)
	freeze = true
	add_to_group(&"SpearStuck")
	
	if abs(angle_difference(rotation, 0)) < abs(angle_difference(rotation, PI)):
		rotation = 0
	else:
		rotation = PI
