extends Node2D

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
	
	if item.stuck: return INF
	
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
	
	#mark for cleanup on cycle
	item.remove_from_group(&"Loose")
	
	held_item = nearest_item
	
	#remove glow
	item.set_glow(false)
	
	item.set_process(false)
	item.freeze = true
	
	await get_tree().process_frame
	
	item.reparent(self)
	
	#move the item closer to indicate it has been picked up
	item.global_position = global_position
	
	item._on_grab()
	
	$Grab.play()

func drop(item:Item):
	
	held_item = null
	
	#mark for cleanup on cycle
	item.add_to_group(&"Loose")
	
	item.set_process(true)
	item.freeze = false
	
	#give back to scene
	item.reparent(get_tree().current_scene)
	
	$Grab.play()

func throw(item:Item):
	
	drop(item)
	
	#move item out of the way of the gound
	item.translate(-item.get_gravity().normalized() * 6.0)
	
	#yeet
	item.linear_velocity = last_horizontal_facing * item.throw_strength
	
	item._on_throw()
	
	$Throw.play()

func eat_held():
	if !is_instance_valid(held_item):
		return
	
	if held_item.food_points:
		profile.current_food += held_item.food_points
		held_item.free()
	
	$Eat.play()

#endregion
