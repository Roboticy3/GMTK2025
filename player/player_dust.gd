extends GPUParticles2D

@export var character:CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var facing:Vector2 = character.facing
	if facing.y == 0:
		facing.y = 1
	if facing.x == 0:
		facing.x = 1
	
	scale = facing

func _ready():
	dust()

func dust():
	emitting = true
