extends GPUParticles2D

@export var character:CharacterBody2D

func _ready() -> void:
	dust()
	if !character:
		set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var facing:Vector2 = character.facing
	if facing.y == 0:
		facing.y = 1
	if facing.x == 0:
		facing.x = 1
	
	scale = facing

signal started
func dust():
	started.emit()
	emitting = true
