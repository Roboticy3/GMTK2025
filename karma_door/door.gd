extends Node2D

@export var level:int
@export var trigger:Area2D

@onready var level_display := $Collider/Level
@onready var anim_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_display.set_karma(level)
	trigger.body_entered.connect(_on_body_entered)

func _on_body_entered(body:Node2D):
	if body.is_in_group(&"Player") and GameManager.profile.current_karma >= level:
		anim_player.play("open")
