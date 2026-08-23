extends Node
class_name DialogueParser

#Node that takes a JSON file consisting of an array of dictionaries
#Each dictionary contains a set of data that will be different per project needs
#So this just needs to pass the dictionary to the scene that displays the dialogue

@export var repeat : bool = false
@export var auto_start : bool = false
@export_file("*.json","*.vvn") var load_from_file: String
@export var backup_conversation: Array[Dictionary] = [{"text"="oops"}]

var parsed_conversation = []
var parsed_translation = []
var conditions : Array[String] = []
var conversation_length = 0
var seek_branch : bool = false
var branch : String = ""
var reading = -1
var paused = false

signal conversation_end
signal line_read(line:int,linedata)
signal conversation_signal(variables)

# Called when the node enters the scene tree for the first time.

func _ready():
	read_from_file(load_from_file)
	for condition in DialogueServer.persistent_conditions:
		inject_condition(condition)
	if auto_start:
		read()
	pass # Replace with function body.

func grab_json(path : String = load_from_file) :
	var readFile = read_from_file()
	if readFile :
		parsed_conversation = readFile
	else :
		parsed_conversation = backup_conversation
	
	conversation_length = parsed_conversation.size()

func read_from_file(path : String = load_from_file):
	var rawFile = FileAccess.open(path,FileAccess.READ)
	var rawText
	var parsedText
	if rawFile != null:
		rawText = rawFile.get_as_text()
		parsedText = JSON.parse_string(rawText)
	if parsedText != null:
		return parsedText
	return null

func read(index : int = reading + 1):
	if paused : return null ##Just? just kill the function if it's paused????? DUH##
	
	if index >= parsed_conversation.size():
		conversation_end.emit()
		if !repeat :
			paused = true
			return null
		else :
			branch = ""
			conditions = []
			seek_branch = false
			index = 0
	##########SEEK THE CORRECT THING TO READ FIRST###########
	
	var line_branch = parsed_conversation[index].get("begin_branch")
	var line_merge = parsed_conversation[index].get("merge_branches")
	match seek_branch: 
		false: 
			if line_branch != null && line_branch != branch || line_merge != null:
				while index < conversation_length-1: # seek through the dialogue until it finds the right branch or reaches the end of the file
					if line_merge is Array:
						if line_merge == [] || line_merge.has(branch):
							break
					index += 1
					line_branch = parsed_conversation[index].get("begin_branch")
					line_merge = parsed_conversation[index].get("merge_branches")
		true: # if in a dialogue branch, check if the parsed_conversation[index]currently being read part of that branch
			while index < conversation_length-1 && line_branch != branch: # seek through the dialogue until it finds the right branch or reaches the end of the file
				index += 1
				line_branch = parsed_conversation[index].get("begin_branch")
				line_merge = parsed_conversation[index].get("merge_branches")
			seek_branch = false
	
	#####THEN PROCESS WHAT'S ON THE NEW LINE, THE NEW LINE GOD DAMN IT#####
	
	var negative_conditions = parsed_conversation[index].get("negative_conditions")
	if negative_conditions is Dictionary:
		for condition in negative_conditions.keys():
			if !conditions.has(condition) && negative_conditions[condition] is Dictionary:
				for key in negative_conditions[condition].keys():
					parsed_conversation[index][key] = negative_conditions[condition][key]
	
	var positive_conditions = parsed_conversation[index].get("positive_conditions")
	if positive_conditions is Dictionary:
		for condition in positive_conditions.keys():
			if conditions.has(condition) && positive_conditions[condition] is Dictionary:
				for key in positive_conditions[condition].keys():
					parsed_conversation[index][key] = positive_conditions[condition][key]
	print(conditions)
	var line_signal = parsed_conversation[index].get("signal")
	if line_signal != null :
		conversation_signal.emit(line_signal)
	
	var choices = parsed_conversation[index].get("choices")
	if choices != null:
		paused = true
	
	var go_to = parsed_conversation[index].get("go_to")
	if go_to is int || go_to is float :
		reading = go_to-1
		seek_branch = false
	else :
		reading = index
	
	line_read.emit(index,parsed_conversation[index])
	
	#######CLOSE AND AUTOSCROLL AFTER EMITTING SIGNALS YOU FRUIT#######
	var autoScroll = parsed_conversation[index].get("autoscroll")
	if autoScroll is bool:
		if autoScroll:
			read(index+1)
		
	var close = parsed_conversation[index].get("close")
	if close :
		conversation_end.emit()
	
	return parsed_conversation[index]

func inject_condition(cond : String):
	conditions.append(cond)

func retract_condition(cond : String):
	while conditions.has(cond):
		conditions.erase(cond)

func make_choice(choiceString : String):
	branch = choiceString
	seek_branch = true
	paused = false
	pass

func _process(delta):
	if Input.is_action_just_pressed("debug_progress") && !paused:
		var rawRead = read()
		if rawRead != null :
			print(str(parsed_conversation.find(rawRead))+":"+str(rawRead))

func _on_conversation_end():
	DialogueServer.skippable_scenes[load_from_file] = conditions
	pass # Replace with function body.
