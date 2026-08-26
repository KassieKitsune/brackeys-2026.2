extends Node

@export var thread_count : int = 4
var threads : Array[Thread] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in thread_count:
		threads.append(Thread.new())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
