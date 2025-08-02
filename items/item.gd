class_name Item extends RigidBody2D

@export var glow_material:Material
@export var throw_strength := 1000.0
@export var food_points := 0

var stuck := false
var flying := false
var time_in_air := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if flying:
		time_in_air += delta

func _on_body_entered(body:Node):
	flying = false

func set_glow(to:bool):
	if to: $Sprite2D.material = glow_material
	else: $Sprite2D.material = null

func _on_throw():
	flying = true
	look_at(global_position + linear_velocity)

func _on_grab():
	rotation = -90.0

signal grabbed()
