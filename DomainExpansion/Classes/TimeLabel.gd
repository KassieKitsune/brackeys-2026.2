extends Label
class_name TimerDisplay

@export var timer_input : Timer
@export_enum("Time Left","Time Elapsed") var mode : int = 0
@export var decimal_accuracy : int = 0

var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	match mode:
		0:
			time = timer_input.time_left
		1:
			time += delta
	text = time_to_string(time)
	pass

func time_to_string(seconds : float):
	var hours : int
	var minutes : int
	minutes = int(seconds-int(seconds)%60)/60
	seconds -= int(seconds-int(seconds)%60)
	hours = (minutes-(minutes%60))/60
	var htext = str(hours) + ":"
	var mtext = str(minutes).lpad(2,"0") + ":"
	seconds = round(seconds*pow(10,decimal_accuracy))/pow(10,decimal_accuracy)
	var stext = str(seconds)
	return (htext+mtext+stext)
	pass
