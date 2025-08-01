extends Controller

var eat_timer:Timer
func _ready() -> void:
	eat_timer = Timer.new()
	eat_timer.autostart = false
	eat_timer.one_shot = true
	eat_timer.wait_time = 0.5
	
	add_child(eat_timer)
	eat_timer.timeout.connect(eat_loop)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	main_axis = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	up = Input.is_action_pressed("ui_up")
	jump = Input.is_action_pressed("ui_accept")
	
	jump_started = Input.is_action_just_pressed("ui_accept")
	
	grab = Input.is_action_just_pressed("grab")
	if grab and eat_timer.is_stopped() and !eat:
		eat_timer.start(eat_timer.wait_time)
	
	if Input.is_action_just_released("grab"):
		eat_timer.stop()
	
	throw = Input.is_action_just_pressed("throw")

func eat_loop():
	eat = true
	get_tree().create_timer(0.5).timeout.connect(func (): 
		eat = false
	)
