extends Control

@export var text_dependency : Control
@export var translate : bool = true
@export var dialogue_source : DialogueParser
@export var monitor_displays : Array[DialogueTextDisplay]
@export_file("*.gd") var button_script : String = "res://DomainExpansion/VN & Dialogue Engine/Scripts/ChoiceButton.gd"

var bScript
var bDict = []
var choiceMemory : Array[String] = []

func _ready():
	bScript = ResourceLoader.load(button_script)
	choiceMemory.append_array(DialogueServer.forbidden_choices)
	if dialogue_source != null :
		dialogue_source.line_read.connect(_on_line_read)

func add_choice( choiceKey : String, choiceText : String = choiceKey):
	var new_button : Button = Button.new()
	new_button.set_script(bScript)
	new_button.choice = choiceKey
	new_button.text = choiceText
	new_button.history = %VNHistoryLayer
	#new_button.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
	if choiceMemory.has(choiceKey):
		new_button.disabled = true
	add_child(new_button)
	new_button.pressed.connect(_on_choice_made.bind(new_button.choice))
	bDict.append(new_button)
	return new_button
	
func clear_choices():
	bDict = []
	for child in get_children():
		if child is Button :
			child.queue_free()
	pass

func _on_line_read(index,lineData:Dictionary):
	var line_choices = lineData.get("choices")
	var transChoices = null
	if DialogueServer.translate && translate :
		if dialogue_source.parsed_translation is Array:
			if dialogue_source.parsed_translation.size() > 0: # only if the parser is holding a translation
				if dialogue_source.parsed_translation[index] is Dictionary: # only if the translation lines are set up as dict
					transChoices = dialogue_source.parsed_translation[index].get("choices") #each translation's lines should sync up with the appropriate core conversation

	if line_choices is Array:
		for cIndex in line_choices.size():
			var choiceText = line_choices[cIndex]
			if transChoices is Array :
				choiceText = transChoices[cIndex]
			elif transChoices is Dictionary :
				choiceText = transChoices[line_choices[cIndex]]
			
			var new_choice = add_choice(line_choices[cIndex],choiceText)
			
			if new_choice != null:
				new_choice.grab_focus()
	elif line_choices is Dictionary:
		for choice in line_choices.keys():
			var choiceText = line_choices[choice]
			if transChoices is Dictionary :
				choiceText = transChoices[choice]
				
			var new_choice = add_choice(choice,choiceText)
			
			if new_choice != null : 
				new_choice.grab_focus()
	pass

func _on_choice_made(choice):
	dialogue_source.make_choice(choice)
	choiceMemory.append(choice)
	print(choice)
	match check_exhaustion():
		true:
			dialogue_source.inject_condition("choices_exhausted")
			pass
		false:
			dialogue_source.retract_condition("choices_exhausted")
			pass
	dialogue_source.read()
	clear_choices()

func check_exhaustion():
	var exhausted = true
	for button in bDict:
		if button is BaseButton :
			if !choiceMemory.has(button.choice):
				exhausted = false
			else :
				button.set_pressed_no_signal(false)
	return exhausted
