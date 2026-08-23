extends Node

@export var dialogue_scene : PackedScene = ResourceLoader.load("res://DomainExpansion/VN & Dialogue Engine/Template Scenes/VisualNovelDialogue.tscn")

@export_dir var conversation_folder : String = "res://DomainExpansion/VN & Dialogue Engine/ExampleMaterials/Scenes/"
@export_dir var background_folder : String = "res://DomainExpansion/VN & Dialogue Engine/ExampleMaterials/Scenes/Backgrounds"
@export var background_extensions : Array[String] = [".png",".jpg"]
@export var conversation_extensions : Array[String] = [".json"]
@export var default_background : Texture2D

@export_category("Translation")
@export var translate : bool = true
@export var default_language : String = "English"
@export_dir var translations_folder : String = "user://Translations"

@export_category("Skip")
@export_file var skip_memory_location : String = "user://SkipMemory.json"

var current_dialogue = ""
var current_conversation = ""
var current_parser : DialogueParser
var persistent_conditions : Array[String]
var forbidden_choices : Array[String] = []
var language : String = default_language

signal dialogue_start(conversation:String)
signal dialogue_end(conversation:String)

func _ready():
	if DirAccess.open(translations_folder) == null:
		create_translation_folder()
		pass

func create_translation_folder():
	var tDir = DirAccess.open("user://")
	tDir.make_dir_absolute(translations_folder)

func open_dialogue(conversation:String):
	if current_conversation == conversation :
		return
	var requested_path = request_conversation_path(conversation)
	var translation_path = request_translation(language,conversation)
	if requested_path != null:
		var new_dialogue = dialogue_scene.instantiate()
		if new_dialogue != null:
			new_dialogue.conversation_file = requested_path
			current_dialogue = new_dialogue
			current_conversation = conversation
			add_child(new_dialogue)
			current_parser = new_dialogue.dialogue_source
			if translate :
				if language != default_language && language != "" && translation_path != null:
					new_dialogue.dialogue_source.parsed_translation = new_dialogue.dialogue_source.read_from_file(translation_path,conversation_extensions[0])
			for condition in persistent_conditions :
				new_dialogue.dialogue_source.conditions.append(condition)
			await get_tree().process_frame
			new_dialogue.dialogue_source.read()
			dialogue_start.emit(conversation)


func request_conversation_path(title:String,ext:String=conversation_extensions[0]):
	print(ext)
	var subdirectories = title.rsplit("/",2)[0]
	var folder = conversation_folder
	if subdirectories != title :
		title = title.trim_prefix(subdirectories+"/")
		folder = folder +"/"+ subdirectories
	var conversationDirectory = DirAccess.open(folder)
	
	if conversationDirectory != null :
		
		conversationDirectory.list_dir_begin()
		
		var conversation = conversationDirectory.get_next()
		while conversation != "":
			if conversation.begins_with(title) && conversation.ends_with(ext):
				var fullPath = folder+"/"+conversation
				conversationDirectory.list_dir_end()
				return fullPath
			conversation = conversationDirectory.get_next()
	return null

func request_translation(language : String, conversation : String):
	var subdirectories = conversation.rsplit("/",2)[0]
	var folder = translations_folder + "/" + language
	if subdirectories != conversation :
		conversation = conversation.trim_prefix(subdirectories+"/")
		folder = folder +"/"+ subdirectories
	
	var translationDirectory =  DirAccess.open(folder)
	if translationDirectory != null :
		
		translationDirectory.list_dir_begin()
		
		var translation = translationDirectory.get_next()
		while translation != "":
			if translation.begins_with(conversation) && translation.ends_with(".json"):
				var fullPath = translations_folder+"/"+language+"/"+translation
				translationDirectory.list_dir_end()
				return fullPath
			translation = translationDirectory.get_next()
	return null

func request_background(bg : String ):
	var subdirectories = bg.rsplit("/",2)[0]
	var backgroundFolder = background_folder
	if subdirectories != bg :
		bg = bg.trim_prefix(subdirectories+"/")
		backgroundFolder = backgroundFolder +"/"+ subdirectories
	var backgroundDirectory = DirAccess.open(backgroundFolder)
	
	var returnBg : Array[Texture2D] 
	
	if backgroundDirectory != null :
		
		backgroundDirectory.list_dir_begin()
		
		var background = backgroundDirectory.get_next()
		while background != "":
			if background.contains(bg) && background.ends_with(".import"):
				background = background.trim_suffix(".import")
				for extension in background_extensions:
					if background.ends_with(extension) :
						return ResourceLoader.load(background_folder+"/"+background)
						backgroundDirectory.list_dir_end()
						break
			background = backgroundDirectory.get_next()
			
	return null
