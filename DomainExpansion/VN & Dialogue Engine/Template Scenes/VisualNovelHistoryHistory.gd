extends Control

@export var dialogue_source : DialogueParser
@export var text_key : String = "text"
@export var speaker_key : String = "character"

@onready var list = %EntryList
@onready var entryTemplate = %Entry
@onready var speakerFont:Font = entryTemplate.get_node("Speaker").get_theme_font("")

var speakerLabels : Array[Label] = []
var LabelSize : int = 0
func _ready():
	if dialogue_source != null:
		dialogue_source.line_read.connect(_on_line_read)

func _on_line_read(index:int,lineData:Dictionary):
	var sourceLine : Dictionary = lineData
	if DialogueServer.translate: # use translation file's keys only if available
		if dialogue_source.parsed_translation is Array:
			if dialogue_source.parsed_translation.size() > 0: # only if the parser is holding a translation
				if dialogue_source.parsed_translation[index] is Dictionary: # only if the translation lines are set up as dict
					sourceLine = dialogue_source.parsed_translation[index]
	
	var entryText = sourceLine.get(text_key)
	var entrySpeaker = sourceLine.get(speaker_key)
	
	add_entry(entrySpeaker,entryText)

func add_entry(entrySpeaker,entryText):
	if entryText is String:
		var entry = entryTemplate.duplicate()
		list.add_child(entry)
		entry.get_node("Text").text = entryText
		#entry.get_node("Text").bbcode_text = entryText
		var sLabel : Label = entry.get_node("Speaker")
		
		if entrySpeaker is String:
			var sLength = speakerFont.get_string_size(entrySpeaker)
			speakerLabels.append(sLabel)
			sLabel.text = entrySpeaker
			
			if sLength.x > LabelSize :
				LabelSize = sLength.x
				for l in speakerLabels:
					l.custom_minimum_size.x = LabelSize
			else :
				sLabel.custom_minimum_size.x = LabelSize
		else :
			if sLabel != null:
				sLabel.text = ""
			sLabel.custom_minimum_size.x = LabelSize
		entry.visible = true
		return entry
	return null

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel") && visible:
		visible = false

func _on_x_button_pressed():
	if visible :
		visible = false
	pass # Replace with function body.

func _on_history_toggle_pressed():
	if !visible : 
		visible = true
	pass # Replace with function body.
