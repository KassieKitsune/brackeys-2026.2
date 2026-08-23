extends CanvasLayer

@export_file("*.json","*.vvn") var conversation_file
@export_file("*.json","*.vvn") var next_scene : String = ""

@export var transition_animation : String = "Fade"
@export var hideable_nodes : Array[Node] 
@onready var dialogue_source = $DialogueParser
@onready var control = $Control



func _ready():
	dialogue_source.load_from_file = conversation_file
	dialogue_source.grab_json()
	dialogue_source.conversation_end.connect(_on_conversation_end)
	dialogue_source.line_read.connect(_on_line_read)
	dialogue_source.conversation_signal.connect(_on_conversation_signal)
	
	control.modulate = Color(1.0,1.0,1.0,0.1)
	var fTween = get_tree().create_tween()
	fTween.tween_property(control,"modulate",Color(1.0,1.0,1.0,1.0),0.2)

func _on_conversation_end():
	var nextget = DialogueServer.request_conversation_path(next_scene)
	var fTween = get_tree().create_tween()
	fTween.tween_property(control,"modulate",Color(1.0,1.0,1.0,0.0),0.5)
	#if transition_animation != "":
		#Transition.blink(transition_animation,transition_animation)
		#await Transition.anim.animation_finished
	await fTween.finished
	if nextget != null:
		DialogueServer.open_dialogue(next_scene)
	queue_free()
	pass

func _on_line_read(lineIndex : int,lineData : Dictionary):
	var line_next = lineData.get("next_scene")
	if line_next != null:
		var nextget = DialogueServer.request_conversation_path(line_next)
		if nextget != null:
			next_scene = line_next
	var line_transition = lineData.get("scene_transition")
	if line_transition is String:
		transition_animation = line_transition
	pass

func _on_conversation_signal():
	pass

func _unhandled_input(event):
	if not event is InputEventJoypadMotion && not event is InputEventMouseMotion:
		for node in hideable_nodes:
			if !node.visible:
				node.visible = true

func _on_hide_toggle_pressed():
	for node in hideable_nodes:
		if node.visible:
			node.visible = false
	pass # Replace with function body.
