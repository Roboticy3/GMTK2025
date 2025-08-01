extends Joint2D

@export var player:CharacterBody2D

@export var item_detector:Area2D
var nearest_item:Item
var held_item:Item

@onready var profile := GameManager.profile
@onready var timer := $EatTimer

#region physics

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_detector.body_entered.connect(_on_item_entered)
	item_detector.body_exited.connect(_on_item_exited)
	timer.timeout.connect(eat_held)

func _on_item_entered(body:Node2D):
	if body is Item and body != held_item and distance_to_item(body) < distance_to_item(nearest_item):
		if nearest_item:
			nearest_item.set_glow(false)
		nearest_item = body
		nearest_item.set_glow(true)

func _on_item_exited(body:Node2D):
	if body is Item:
		body.set_glow(false)
		if body == nearest_item:
			nearest_item = null
			for b in item_detector.get_overlapping_bodies():
				_on_item_entered(b)

func distance_to_item(item:Item) -> float:
	if !item: return INF
	
	return item.global_position.distance_to(global_position)

#endregion

var last_horizontal_facing := Vector2.RIGHT
func _physics_process(delta: float) -> void:
	last_horizontal_facing = player.facing * Vector2.RIGHT if player.facing.x != 0.0 else last_horizontal_facing
	
	var is_grabbing:bool = player.controller.grab
	if is_grabbing and is_instance_valid(nearest_item):
		grab(nearest_item)
	
	var is_throwing:bool = player.controller.throw
	if is_throwing and is_instance_valid(held_item):
		throw(held_item)
		
	
	var is_eating:bool = player.controller.eat
	if is_eating:
		eat_held()

#region action
func grab(item:Item):
	
	if is_instance_valid(held_item):
		drop(held_item)
	
	#tell item its being grabbed
	item.grabbed.emit()
	
	held_item = nearest_item
	
	#remove glow
	item.set_glow(false)
	
	item.reparent(get_tree().root)
	
	#move the item closer to indicate it has been picked up
	var d := distance_to_item(item)
	item.global_position = global_position + Vector2.from_angle(randf_range(0.0, 2 * PI)) * 6.0
	
	#pin to the hand
	node_b = get_path_to(item)
	
	$Grab.play()

func drop(item:Item):
	
	held_item = null
	
	#give back to scene
	item.reparent(get_tree().current_scene)
	
	#remove from pin
	node_b = ""
	
	$Grab.play()

func throw(item:Item):
	
	drop(item)
	
	#cancel out existing momentum
	item.apply_central_impulse(-item.linear_velocity)
	
	#move item out of the way of the gound
	item.translate(-item.get_gravity().normalized() * 6.0)
	
	#yeet
	item.apply_central_impulse(last_horizontal_facing * item.throw_strength)
	
	$Throw.play()

func eat_held():
	if !is_instance_valid(held_item):
		return
	
	if held_item.food_points:
		profile.current_food += held_item.food_points
		held_item.free()
	
	$Eat.play()

#endregion
