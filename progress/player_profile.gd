class_name PlayerProfile extends Resource

@export var story_state := 0

signal food_needed_changed(to:int)
@export var food_needed := 4 :
	set(new_food_needed):
		food_needed = new_food_needed
		food_needed_changed.emit(new_food_needed)

signal max_food_changed(to:int)
@export var max_food := 7 :
	set(new_max_food):
		max_food = new_max_food
		max_food_changed.emit(new_max_food)

signal current_food_changed(to:int)
@export var current_food := 1 :
	set(new_current_food):
		current_food = clampi(new_current_food, 0, max_food)
		current_food_changed.emit(current_food)

@export var current_food_at_cycle := 1

@export var max_karma := 5

signal current_karma_changed(to:int)
@export var current_karma := 0 :
	set(new_current_karma):
		current_karma = clampi(new_current_karma, 0, max_karma)
		current_karma_changed.emit(current_karma)
