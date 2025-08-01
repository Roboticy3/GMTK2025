extends Node

var profile := GameManager.profile

#slot empty and slot full animations
@export var slot_animations:SpriteFrames

#spacing of slots in pixels
@export var spacing := 32
@export var bar_spacing := 24

@export var bar:Node2D

func _ready() -> void:
	profile.food_needed_changed.connect(update_bar.unbind(1))
	update_bar()
	
	profile.max_food_changed.connect(rebuild_pips.unbind(1))
	rebuild_pips()
	
	profile.current_food_changed.connect(update_pips)
	update_pips(profile.current_food)

func update_bar():
	var tween := bar.create_tween()
	tween.tween_property(bar, "position:x", float(spacing * profile.food_needed), 1.0)

var pips:Array[AnimatedSprite2D] = []
var food_level := 0
func rebuild_pips():
	for c in get_children():
		if c.is_in_group("Pips"):
			c.queue_free()
	
	pips = []
	for i in profile.max_food:
		var pip := AnimatedSprite2D.new()
		add_child(pip)
		pip.sprite_frames = slot_animations
		pip.position.x = spacing * i
		if i >= profile.food_needed:
			pip.position.x += bar_spacing
		pips.append(pip)

signal pip_filled(i:int)
func update_pips(new_food_level:int):
	for i in range(food_level, new_food_level, 1):
		if i < pips.size():
			pips[i].play("fill")
			pip_filled.emit(i)
	food_level = new_food_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
