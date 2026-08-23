extends Button

@onready var dialogue_source : DialogueParser = %DialogueParser

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_pressed)
	pass # Replace with function body.

func _on_pressed():
	if dialogue_source is DialogueParser:
		while dialogue_source.reading < dialogue_source.parsed_conversation.size() && !dialogue_source.paused:
			await get_tree().create_timer(get_process_delta_time()).timeout
			dialogue_source.read()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
