extends Timer
class_name InputRepeat

@export var repeat_inputs : Array[String]

func _ready():
	
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for inp in repeat_inputs:
		if Input.is_action_just_pressed(inp):
			stop()
			repeat(inp)
			break
	pass

func repeat(input : String):
	if Input.is_action_pressed(input):
		var event = InputEventAction.new()
		event.action = input
		event.pressed = true
		Input.parse_input_event(event)
		start()
		await timeout
		var event2 = InputEventAction.new()
		event2.action = input
		event2.pressed = false
		Input.parse_input_event(event2)
		repeat(input)
	pass
