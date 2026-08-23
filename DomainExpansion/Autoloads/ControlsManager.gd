extends Node

enum CONTROLLER{KEY,GAMEPAD,TOUCH}

@export_range(0.0,1.0) var touch_move_deadzone : float = 0.2
@export_range(0.0,1.0) var touch_sprint_deadzone : float = 0.9

var controller = CONTROLLER.KEY
var swipe_start:Vector2
var swipe_end:Vector2
var swipe_duration:float = 0.0
var swipe_min:float = 100.0

signal ControllerChanged
signal swipe(direction:Vector2)
# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().size_changed.connect(_on_vp_changed)
	var vp = get_viewport().get_visible_rect().size
	swipe_min = min(vp.x,vp.y)*0.25
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	swipe_duration += delta
	pass

func _input(event):
	if event is InputEventKey || event is InputEventMouseButton:
		controller = CONTROLLER.KEY
		ControllerChanged.emit(controller)
	elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
		controller = CONTROLLER.GAMEPAD
		ControllerChanged.emit(controller)
	elif event is InputEventScreenTouch || event is InputEventScreenDrag:
		controller = CONTROLLER.TOUCH
		ControllerChanged.emit(controller)
	
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		match event.pressed:
			true:
				swipe_start = event.position
				swipe_duration = 0.0
			false:
				swipe_end = event.position
				if swipe_duration < 0.2 && swipe_start.distance_to(swipe_end) >= swipe_min:
					swipe.emit(swipe_start.direction_to(swipe_end))
					print(swipe_start.direction_to(swipe_end))

func _on_vp_changed():
	var vp = get_viewport().get_visible_rect().size
	swipe_min = min(vp.x,vp.y)*0.25
	pass
