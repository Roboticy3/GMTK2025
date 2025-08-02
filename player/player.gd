extends CharacterBody2D

#region constants
const SPEED = 110.0
const ACCEL := 500.0
const TURN_ACCEL := 1000.0

const JUMP_VELOCITY = -250.0
const COYOTE_TIME := 0.25

const ROPE_ACCEL := 1500.0

const TUNNEL_SPEED := 90.0
#must be more than TUNNEL_SPEED for tunnel_boosting animation flag to be set 
#	properly
const TUNNEL_BOOST := 150.0
#endregion

#region vectors
var time_in_air := 0.0
var facing:Vector2
#endregion

#region flags
#flags
#some are used for logic, but all are mainly for animation controls

var climbing_rope := false
#tunnels are a type of rope that is climbed automatically and cannot be dismounted
var tunneling := false

var tunnel_boosting := false
var walking := false
var turning := false
var jumping := false
var falling := false
var touching_tunnel := false

var idling := false
#endregion

#region discrete
var touching_rope_type:StringName
var current_tile_map_cell:Variant
var current_tile_map_layer:TileMapLayer
var current_spoon_rope:Spooear
var controller:Controller
#endregion

#region exports
@export var tilemap_detector:Area2D
@export var item_detector:Area2D
#endregion

#region motion functions
func update_fall(delta:float) -> void:
	if (is_on_floor() or (touching_tunnel and !tunneling) or (climbing_rope and !tunneling)):
		time_in_air = 0.0
		jumping = false
		falling = false
		if !climbing_rope:
			velocity -= velocity.project(get_gravity())
	else:
		time_in_air += delta
		
		velocity += get_gravity() * delta
		
		if velocity.y > 0.0:
			falling = true
			jumping = false

func can_jump() -> bool:
	return controller.jump_started and time_in_air < COYOTE_TIME and !tunneling

signal dust()
func try_jump():
	if can_jump():
		if is_on_floor():
			dust.emit()
		jumping = true
		velocity.y = JUMP_VELOCITY
		
		if !tunneling:
			climbing_rope = false
	
	if tunneling:
		if controller.jump_started:
			velocity += facing * TUNNEL_BOOST
			tunnel_boosting = true
			dust.emit()

func try_walk(axis:Vector2, delta:float):
	if climbing_rope: return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if axis.x:
		var accel := ACCEL
		if signf(axis.x) != signf(velocity.x):
			accel = TURN_ACCEL
			turning = true
			if is_on_floor():
				dust.emit()
		else:
			set_deferred("turning", false)
		velocity.x = move_toward(velocity.x, axis.x * SPEED, accel * delta)
		walking = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		walking = false

func try_rope(axis:Vector2, delta:float):
	if touching_tunnel: 
		var fail := false
		if !tunneling: match touching_rope_type:
			&"Horizontal":
				if axis.x == 0.0: fail = true
			&"Vertical":
				if axis.y == 0.0: fail = true
			&"Cross":
				if axis.is_zero_approx(): fail = true
		
		tunneling = !fail
	else:
		tunneling = false
	
	if !climbing_rope:
		
		if touching_rope_type != &"" and (controller.up or tunneling):
			climbing_rope = true
			walking = false
		
	if climbing_rope:
		match touching_rope_type:
			&"Horizontal":
				rope_horizontal(axis, delta)
			&"Vertical":
				rope_vertical(axis, delta)
			&"Cross":
				if abs(axis.x) > abs(axis.y):
					rope_horizontal(axis, delta)
				else:
					rope_vertical(axis, delta)
			&"":
				climbing_rope = false
				return
		
		if !tunneling and is_on_floor() and axis.y > 0.0:
			climbing_rope = false

		walking = true

	#this is kina misc, but if we're in a tunnel, and we're only moving at 
	#TUNNEL_SPEED or slower, that means we aren't tunnel boosting
	if tunneling:
		if velocity.length() <= TUNNEL_SPEED:
			tunnel_boosting = false
	
func rope_horizontal(axis:Vector2, delta:float):
	if axis.x:
		velocity.x = move_toward(velocity.x, axis.x * TUNNEL_SPEED, ROPE_ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ROPE_ACCEL * delta)
	
	if current_tile_map_cell and current_tile_map_layer:
		#get centered position of the current tile in local space
		#	then project it to global space and align the rope motion to
		#	the center of the tile
		var local_center := current_tile_map_layer.map_to_local(current_tile_map_cell)
		var center := current_tile_map_layer.to_global(local_center)
		global_position.y = center.y
	if current_spoon_rope:
		global_position.y = current_spoon_rope.global_position.y
		
	velocity.y = 0.0

func rope_vertical(axis:Vector2, delta:float):
	if axis.y:
		velocity.y = move_toward(velocity.y, axis.y * TUNNEL_SPEED, ROPE_ACCEL * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, ROPE_ACCEL * delta)
	
	if current_tile_map_cell and current_tile_map_layer:
		#get centered position of the current tile in local space
		#	then project it to global space and align the rope motion to
		#	the center of the tile
		var local_center := current_tile_map_layer.map_to_local(current_tile_map_cell)
		var center := current_tile_map_layer.to_global(local_center)
		global_position.x = center.x
	
	velocity.x = 0.0

#endregion

#region post motion functions

func update_colliding_tile():
	if current_tile_map_layer:
		current_tile_map_cell = current_tile_map_layer.local_to_map(
			current_tile_map_layer.to_local(global_position)
		)
	else:
		current_tile_map_cell = null

func update_rope_type(axis):
	update_rope_type_tilemap(axis)
	update_rope_type_spoon(axis)
	
	if current_spoon_rope and current_tile_map_layer and current_tile_map_cell:
		var tile_local := current_tile_map_layer.map_to_local(current_tile_map_cell)
		var tile_global := current_tile_map_layer.to_global(tile_local)
		var tile_distance := tile_global.distance_to(global_position)
		var spoon_distance := current_spoon_rope.global_position.distance_to(global_position)
		if spoon_distance < tile_distance:
			current_tile_map_layer = null
		else:
			current_spoon_rope = null

func update_rope_type_tilemap(axis):
	var found_tile_map:TileMapLayer
	touching_rope_type = &""
	touching_tunnel = false
	
	for b in tilemap_detector.get_overlapping_bodies():
		if b is TileMapLayer:
			found_tile_map = b
			
			if !current_tile_map_cell: continue
			
			var current_tile = b.get_cell_tile_data(current_tile_map_cell)
			if current_tile and current_tile.has_custom_data("rope_type"):
				touching_rope_type = current_tile.get_custom_data("rope_type")

			if current_tile and current_tile.has_custom_data("is_tunnel"):
				touching_tunnel = current_tile.get_custom_data("is_tunnel")
	current_tile_map_layer = found_tile_map

func update_rope_type_spoon(axis):
	var spoon_rope:Spooear
	for b in item_detector.get_overlapping_bodies():
		if b is Spooear and b.stuck:
			touching_rope_type = &"Horizontal"
			spoon_rope = b
	current_spoon_rope = spoon_rope

func update_facing():
	if !velocity.is_zero_approx():
		facing = velocity.normalized().snapped(Vector2.ONE)

func update_idling():
	idling = !jumping and !walking and !climbing_rope
#endregion

func _physics_process(delta: float) -> void:
	
	var axis := controller.main_axis
	
	#call input functions
	try_jump()

	try_walk(axis, delta)
	try_rope(axis, delta)

	#apply motion
	move_and_slide()
	
	#update state
	update_colliding_tile()
	update_rope_type(axis)
	update_facing()
	update_fall(delta)
	update_idling()
