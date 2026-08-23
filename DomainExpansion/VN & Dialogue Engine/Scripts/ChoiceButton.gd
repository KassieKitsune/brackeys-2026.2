extends Button

@export var dialogue_source : DialogueParser
var choice : String = ""
var history : Node

func _ready():
	button_down.connect(_on_button_down)
	pass # Replace with function body.

func _on_button_down():
	if history != null:
		var entry = history.add_entry("","[color=red]"+text+"[/color]")
	pass
