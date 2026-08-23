extends Node
class_name DialogueLevelLoader


var next_scene : String = ""

@export var accepted_extensions : Array[String] = [".tscn"]
@export var transition_animation : String = "Fade"
@export_dir var level_folder : String

@onready var dialogue_source : DialogueParser = %DialogueParser

func _ready():
	dialogue_source.conversation_end.connect(_on_level_end)
	dialogue_source.line_read.connect(_on_line_read)

func _on_level_end():
	if next_scene != "":
		Transition.to_scene_path(next_scene,transition_animation,transition_animation)
	pass

func _on_line_read(lineIndex : int,lineData : Dictionary):
	var line_next = lineData.get("next_scene")
	if line_next != null:
		var nextget = request_level_path(line_next)
		if nextget != null:
			next_scene = nextget
	var line_transition = lineData.get("scene_transition")
	if line_transition is String:
		transition_animation = line_transition
	pass

func request_level_path(title):
	var levelDirectory = DirAccess.open(level_folder)
	if levelDirectory != null :
		
		levelDirectory.list_dir_begin()
		
		var level = levelDirectory.get_next()
		while level != "":
			if level.ends_with(".remap"):
				level = level.rstrip(".remap")
			if level.begins_with(title) && level.ends_with(".tscn"):
				var fullPath = level_folder+"/"+level
				print(fullPath)
				return fullPath
			level = levelDirectory.get_next()
	return null
