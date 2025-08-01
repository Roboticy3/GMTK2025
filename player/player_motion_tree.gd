extends AnimationTree

@export var character:CharacterBody2D

@export var props_to_params:Dictionary[StringName, Array]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for p in props_to_params:
		for param in props_to_params[p]:
			if !param: continue
			self[param] = character[p]
