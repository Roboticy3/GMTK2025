extends Node

@export var radii:PackedFloat32Array = [
	16.0, 21.0, 24.0, 24.0, 24.0, 24.0
]
@export var sprite_frames:SpriteFrames
@export var pip_seconds := 15.0

func _ready() -> void:
	reconnect()
	GameManager.profile_changed.connect(reconnect)

func reconnect():
	build_pips()
	GameManager.cycle.connect(func ():
		set_process(false)
		build_pips.call_deferred()
	)

var pips:Array[AnimatedSprite2D]
func build_pips():
	
	for c in get_children():
		c.queue_free()
	
	pips = []
	var pip_count := floori(GameManager.cycle_timer.wait_time / pip_seconds)
	for i in pip_count:
		var p := AnimatedSprite2D.new()
		p.sprite_frames = sprite_frames
		p.position = Vector2.UP * radii[GameManager.profile.current_karma]
		var c := Node2D.new()
		
		var c_tween := c.create_tween()
		c_tween.tween_property(c, "rotation", -2.0 * PI * float(i + 1) / float(pip_count), 1.0)
		
		c.add_child(p)
		add_child(c)
		
		pips.append(p)
		
		p.global_scale /= p.global_scale
	
	set_process(true)

var empty_point:int = 0
func update_pips():
	var current_time := GameManager.cycle_timer.time_left
	var new_empty_point := floori(current_time / pip_seconds)
	if new_empty_point == empty_point:
		return
	
	if new_empty_point < empty_point:
		for i in range(new_empty_point, empty_point):
			if i >= pips.size():
				break
			pips[i].play("empty")
	else:
		for i in range(empty_point, new_empty_point):
			if i >= pips.size():
				break
			pips[i].play("fill")
	empty_point = new_empty_point

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_pips()
